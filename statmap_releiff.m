function [ subj ] = statmap_releiff(subj,data_patname,regsname,selname,new_map_patname,extra_arg)
%RUNRELIEFF Summary of this function goes here
%   Detailed explanation goes here

if nargin<6
  error('Need 6 arguments, even if extra_arg is empty');
end

defaults.cur_iteration = NaN;
defaults.whole_func_name = '';
defaults.runs_selname = '';
defaults.startpoints_name = '';
defaults.censor_1d_name = '';
defaults.afni_location = '';
defaults.deconv_args = [];
defaults.regs_1d_name = '';
defaults.contrast_mat = [];
defaults.bucket_name = '';
defaults.aux_path_name = '';
defaults.overwrite_buckets = false;
defaults.mask_filename = '';
defaults.exec_filename = '';
defaults.mc_params_txt = '';
defaults.goforit = 0;
defaults.run_script = true;
args = propval({extra_arg},defaults);

args = process_args(data_patname,regsname,args);

regs = get_mat(subj,'regressors',regsname);
sel  = get_mat(subj,'selector',selname);

runs = get_mat(subj,'selector',args.runs_selname);

[nConds nTRs] = size(regs);

% the AFNI censor file should contain 1s for all timepoints
% that will be included, and 0s otherwise
%
% UPDATE: there's now a WRITE_OUT_CENSOR_FROM_SEL.M that
% this should call instead
censor = sel';
censor(find(censor~=1)) = 0;
save(args.censor_1d_name,'censor','-ascii');

if ~isempty(args.contrast_mat)
  contrasts = args.contrast_mat;
  % multiply our regressors by contrast matrix (e.g. if you
  % want to use use the GLM like a 1-way omnibus anova,
  % create a CONTRAST_MAT with CREATE_MAIN_EFFECT_CONTRAST)
  regs = [contrasts * regs];
  % the nConds may have changed after REGS was multiplied by
  % the contrast matrix
  nConds = size(regs,1);
end

write_regs_1d(regs,args.regs_1d_name);

sanity_check(regs,sel,args);

% create the startpoints file
startpoints = create_startpoints(runs);
save(args.startpoints_name,'startpoints','-ascii');

[call] = call_3dDeconvolve(args,regsname,nConds);
% args = rmfield(args,'deconv_args');

% don't bother trying to load in the newly-created BRIK if
% we didn't run the shell script
if args.run_script

  masked_by = get_objfield(subj,'pattern',data_patname,'masked_by');

  subj = load_afni_pattern(subj,new_map_patname,masked_by,args.bucket_name, ...
                           'sub_briks',call.last_sub_brik);

  hist = sprintf('Created by statmap_3dDeconvolve');
  subj = add_history(subj,'pattern',new_map_patname,hist);

  created.function = mfilename;
  created.dbstack = dbstack;
  created.data_patname = data_patname;
  created.regsname = regsname;
  created.selname = selname;
  created.extra_arg = extra_arg;
  created.new_map_patname = new_map_patname;
  created.call = call;
  subj = add_created(subj,'pattern',new_map_patname,created);

end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [args] = process_args(data_patname,regsname,args)

% Get all the cells from the cell arrays
if iscell(args.whole_func_name)
  error('Your whole_func_name should be the same for each iteration');
end

if iscell(args.censor_1d_name)
  args.censor_1d_name = args.censor_1d_name{args.cur_iteration};
end

if iscell(args.startpoints_name)
  args.startpoints_name = args.startpoints_name{args.cur_iteration};
end

if iscell(args.regs_1d_name)
  args.regs_1d_name = args.regs_1d_name{args.cur_iteration};
end

if iscell(args.deconv_args)
  args.deconv_args = args.deconv_args{args.cur_iteration};
end

if iscell(args.bucket_name)
  args.bucket_name = args.bucket_name{args.cur_iteration};
end

if iscell(args.exec_filename)
  args.exec_filename = args.exec_filename{args.cur_iteration};
end

% Set the default filenames
if isempty(args.whole_func_name)
  error('Need a WHOLE_FUNC_NAME');
end

if isempty(args.runs_selname)
  error('Need a RUNS_SELNAME');
end

if isempty(args.startpoints_name)
  args.startpoints_name = 'startpoints.txt';
end

if isempty(args.censor_1d_name)
  args.censor_1d_name = sprintf('censor_%s_it%i.1d',data_patname,args.cur_iteration);
end

if isempty(args.regs_1d_name)
  args.regs_1d_name = sprintf('%s_it%i.1d',regsname,args.cur_iteration);
end

if isempty(args.bucket_name)
  args.bucket_name = sprintf('%s_it%i_bucket+tlrc',data_patname,args.cur_iteration);
else
  args.bucket_name = sprintf('%s_%i_bucket+orig',args.bucket_name,args.cur_iteration);
end

if isempty(args.exec_filename)
  args.exec_filename = sprintf('mvpa_3dDeconvolve_%i.sh',args.cur_iteration);
end

if ~isint(args.goforit)
  error('GOFORIT must be set to 0 or the number of warnings to ignore');
end

% if a AUX_PATH_NAME has been specified, and it doesn't exist, create it
if ~isempty(args.aux_path_name) & ~exist(args.aux_path_name,'dir')
  dispf('Attempting to create %s',args.aux_path_name);
  [status msg] = mkdir(args.aux_path_name);
  if ~status, error(msg), end
end % checking for existence of AUX_PATH_NAME
  
% prepend AUX_PATH_NAME to all the filenames. if AUX_PATH_NAME is
% empty (the default), this will have no effect, placing everything in
% the current directory. doesn't affect the BUCKET_NAME
fnames = {'startpoints_name', ...
          'censor_1d_name', ...
          'regs_1d_name', ...
          'exec_filename'};
for f=1:length(fnames)
  fname = fnames{f};
  args.(fname) = fullfile(args.aux_path_name, args.(fname));
end % f fnames


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [] = sanity_check(regs,sel,args)

if size(regs,2) ~= size(sel,2)
  error('Different nTRs in regs and selector');
end

if ~isrow(sel)
  error('Your selector needs to be a row vector');
end

if max(sel)>2 | min(sel)<0
  disp('These selectors don''t look like cross-validation selectors');
  error('Are you feeding in your runs by accident?');
end

if ~length(find(regs)) | ~length(find(sel))
  error('There''s nothing for the ANOVA to run on');
end

if exist( sprintf('%s.BRIK',args.bucket_name),'file' ) | exist( sprintf('%s.BRIK.gz',args.bucket_name),'file' )
  if args.overwrite_buckets
    unix(sprintf('rm -f %s.BRIK',args.bucket_name));
    unix(sprintf('rm -f %s.BRIK.gz',args.bucket_name));
    unix(sprintf('rm -f %s.HEAD',args.bucket_name));
  else
    error('You need to delete the existing bucket first - %s',args.bucket_name);
  end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [call] = call_3dDeconvolve(args,regsname,nConds)


% Check the deconv_args, to make sure that none of the fields that
% we're going to deliberately specify have been included in the
% deconv_args too
deconv_args = check_deconv_args(args.deconv_args);

num_stimts = 0;

% Create the condition lines
%
% xxx - the regs 1D filenames should be an optional argument, so that
% we can deal with them in PROCESS_ARGS, rather than inline here
conds_cell = {};
for c=1:nConds
  num_stimts = num_stimts + 1;
  condlabels{c} = sprintf('%s_c%i',regsname,c);
  conds_cell{end+1} = sprintf('-stim_file %i %s -stim_label %i %s \\', ...
			      num_stimts, ...
			      fullfile(args.aux_path_name, ...
                                       sprintf('%s_it%i_c%i.1d',regsname,args.cur_iteration,c)), ...
			      num_stimts, ...
			      condlabels{c} ...
			      );
end % c nConds

% Create the motion parameter lines
motion_cell = {};
if ~isempty(args.mc_params_txt)
  for m=1:6
    num_stimts = num_stimts + 1;
    cur_mc_params_str = sprintf('mc_params%i',m);
    motion_cell{end+1} = sprintf('-stim_file %i ''%s[%i]'' -stim_label %i %s -stim_base %i \\', ...
				 num_stimts, ...
				 args.mc_params_txt, ...
				 m, ...
				 num_stimts, ...
				 cur_mc_params_str, ...
				 num_stimts ...
				 );
  end % m 6
end

user_cell = {};

if ~isempty(deconv_args)
  deconv_names = fieldnames(deconv_args);
  for f=1:length(deconv_names)
    cur_name = deconv_names{f};
    cur_val = deconv_args.(cur_name);
    user_cell{end+1} = sprintf('-%s %s \\',cur_name,cur_val);
  end
end

cl_cell{1} = sprintf( ...
    '%s \\', fullfile(args.afni_location,'3dDeconvolve') );
cl_cell{end+1} = sprintf('-input %s \\',args.whole_func_name);
cl_cell{end+1} = sprintf('-concat %s \\',args.startpoints_name);
cl_cell{end+1} = sprintf('-num_stimts %i \\',num_stimts);
% use DECONV_ARGS instead, e.g. statmap_3d_arg.deconv_args.xjpeg = 'desMtx.jpg';
%
% xxx - better still, there should be an XJPEG argument...
%
% cl_cell{end+1} = sprintf('-xjpeg %s.jpg \\', args.exec_filename);
cl_cell = [cl_cell conds_cell motion_cell];
cl_cell{end+1} = sprintf('-censor %s \\',args.censor_1d_name);
cl_cell{end+1} = sprintf('-bucket %s \\',args.bucket_name);

if args.mask_filename
  cl_cell{end+1} = sprintf('-mask %s \\',args.mask_filename);
end % mask

% it turns out that this should use '1' instead of nConds, since we're
% actually only running a single GLT. but then it turns out that we
% don't actually need this argument at all. see
% http://afni.nimh.nih.gov/afni/community/board/read.php?f=1&i=28157&t=28157#reply_28157
% cl_cell{end+1} = sprintf('-num_glt %d \\',nConds);

% create a GLT line that looks something like:
%   -glt 'SYM: +Reg1 \ +Reg2 \ +Reg3'
% where Reg# is replaced with the stimlabel created above
glt_txt = '';
for c=1:nConds
  glt_txt = sprintf('%s +%s \\',glt_txt,condlabels{c});
end % for c
glt_txt = glt_txt(1:end-2); % get rid of the last slash
cl_cell{end+1} = sprintf('-gltsym ''SYM: %s '' -glt_label 1 statmap_3dDeconvolve \\',glt_txt);

if args.goforit
  cl_cell{end+1} = sprintf('-goforit %i \\',args.goforit);
end

cl_cell = [cl_cell user_cell];
cl_cell{end+1} = '-fout';

disp( sprintf('Wrote the following to %s',args.exec_filename) );
disp('---------------------------------------');

[fid msg] = fopen(args.exec_filename,'wt');
if fid==-1
  error(msg);
end
for line=1:length(cl_cell)
  curline = char(cl_cell{line});
  fprintf(fid,'%s\n',curline);
  disp(curline)
end
fclose(fid);


exec = sprintf('source %s',args.exec_filename);
if args.run_script
  
  [status output] = unix(exec,'-echo');
  if status
    error(output);
  end

  [err info] = BrikInfo(args.bucket_name);
  if err
    error('Problem with BrikInfo %s',args.bucket_name);
  end
  
  last_sub_brik = info.DATASET_RANK(2);
  if ~isequal(last_sub_brik,length(info.BRICK_TYPES))
    warning('Not certain that we''ve got the last sub_brik right');
  end
  
else
  dispf('Wrote out %s, but not running it',args.exec_filename);

  last_sub_brik = NaN;
  status = NaN;
  output = NaN;
  
end


call.deconv_args = deconv_args;
call.cl_cell = cl_cell;
call.exec = exec;
call.last_sub_brik = last_sub_brik;
call.status = status;
call.output = output;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [deconv_args] = check_deconv_args(deconv_args)

if isfield(deconv_args,'bucket')
  warning('Ignoring surplus user-specified bucket');
  deconv_args = rmfield(deconv_args,'bucket');
end

if isfield(deconv_args,'input')
  warning('Ignoring surplus user-specified input');
  deconv_args = rmfield(deconv_args,'input');
end

if isfield(deconv_args,'concat')
  warning('Ignoring surplus user-specified concat');
  deconv_args = rmfield(deconv_args,'concat');
end

if isfield(deconv_args,'num_stimts')
  warning('Ignoring surplus user-specified num_stimts');
  deconv_args = rmfield(deconv_args,'num_stimts');
end

if isfield(deconv_args,'censor')
  warning('Ignoring surplus user-specified censor');
  deconv_args = rmfield(deconv_args,'censor');
end

if isfield(deconv_args,'fout')
  warning('Ignoring surplus user-specified fout');
  deconv_args = rmfield(deconv_args,'fout');
end

if isfield(deconv_args,'glt')
  warning('GLTs not implemented yet');
  deconv_args = rmfield(deconv_args,'glt');
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [startpoints] = create_startpoints(runs)

startpoints = [0 find(runs(2:end) ~= runs(1:end-1))]';
