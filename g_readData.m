% G_READ_DATA                Read in Gramalkn 3.0 data
% 
%     [dat,fid,num_trials] = g_read_data(fname,start_trial,end_trial,rank);
%
%     INPUTS
%     fname       - filename as a string (include extension),
%                   can also be file pointer to previously opened data file
%  
%     OPTIONAL
%     start_trial - Actual trial number
%     end_trial   - Actual trial number (>= START_TRIAL)
%     rank        - Index of trials, this is not the true trial number, 
%                   but rather the ordinal rank. If this is passed in, 
%                   START_TRIAL and END_TRIAL are ignored.
%
%     OUTPUTS
%     dat         - data structure, if multiple trials, struct array
%                   This contains all the fields read using G_READ_PREAMBLE
%                   as well as eye traces and spike times
%     fid         - pointer to data file
%     num_trials  - total number of trials in data file (not in data structure)
%
%     EXAMPLES
%     % to read in all data, pass in filename alone
%     >> dat = g_read_data('filename');
%     % to read in all trials following (and including) a particular trial number (say 10)
%     >> dat = g_read_data('filename',10);
%     % to read in all trials up to (and including) a particular trial number (say 10)
%     >> dat = g_read_data('filename',[],10);
%     % to read in all trials between the START_TRIAL (say 10) and the END_TRIAL (say 20)
%     >> dat = g_read_data('filename',10,20); % this is inclusive
%     % if you just want some data regardless of the actual trial number (say the first 10 trials)
%     >> dat = g_read_data('filename',[],[],1:10);

%     $ Copyright 2001-2003 Brian Lau <blau@cns.nyu.edu> $
%
%     REVISION HISTORY:
%     brian 11.00.01 written based on source code for Gram v.3.0.69
%     brian 01.09.01 also handles new datatype version from Gram v.3.0.77
%     brian 02.08.02 added filters for ERROR and spike garbage
%     brian 02.09.02 changed calling syntax to use actual trial numbers
%                    implemented call to global parameter script
%     brian 07.14.04 modified call to G_READ_EYEDATA to handle multiple
%                    analog channels
%		eddie 07.26.04 added preamble_version to line 88 and 89, and g_read_preamble2 to line 147

function [dat,fid,num_trials] = g_readData(fname,start_trial,end_trial,rank)

%----- Globals, definitions, & constants
initiate_globals;
INT = 'int16';
PREAMBLENGTH = 1024; % bytes (defined as 512 16 bit integers)
BLOCKSIZE = 1024;    % bytes
DEF = 'rawdata';     % Structure definition
PREAMBLE_VERSION_POS = 256;

if nargin == 4
   if ~isempty(start_trial) & ~isempty(end_trial)
      fprintf('START_TRIAL and END_TRIAL parameters ignored');
   end
end

if isstr(fname)
   %----- Open data file assuming little-endian
   [fid,message] = fopen(fname,'rb','ieee-le');
   if fid < 0
       fprintf('\n%s ... %s probably not found.\n',message,fname);
       return
   end
else
   % Assume 'fname' is a pointer and repark it
   fid = fname;
   frewind(fid);
end

% Run through the data file once to grab the blocksizes
num_trials = 1;
temp = zeros(56,1);
while 1
   if num_trials == 1
      % Move to position where dataype version is stored.
      % Reading once is OK, since Gram requires restart when
      % changing between datatype versions.
      fidpos = ftell(fid);
      fseek(fid,164*2,'bof');
      datatype_version = fread(fid,1,INT);
      
      fseek(fid,PREAMBLE_VERSION_POS*2,'bof'); %BOF = begining of file
      preamble_version = fread(fid, 1, INT);
      
      fseek(fid,fidpos,'bof');
   else
      % Move pointer to end of trial
      ind = BLOCKSIZE*sum(blocks);
      fseek(fid,ind,'bof');
   end
   % Read in enough of preamble to get blocksize and trial number
   temp = fread(fid,56,INT);
   if isempty(temp) || length(temp)<56
      break % EOF
   else
      blocks(num_trials) = temp(11);
      trials(num_trials) = temp(56);
      num_trials = num_trials + 1;
   end
end
num_trials = num_trials - 1;
frewind(fid);

%----- Set up the index of trials to read in
if nargin == 1
   % default to read in all trials
   index = 1:num_trials;
elseif nargin == 2 
   % only starting trial requested, ignore trials less than this
   index = find(trials>=start_trial);
elseif nargin == 3
   if isempty(start_trial)
      index = find(trials<=end_trial);
   else
      % start_trial to end_trial, inclusive
      index = find((trials>=start_trial) & (trials<=end_trial));
   end
elseif nargin == 4
   index = rank;
end
index = index(:)';

if isempty(index)
   error('Invalid trial request for G_READ_DATA. Check your syntax & make sure these trials exist.');
end

%----- Read in data
count = 1;
try
	for i = index
       if i ~= 1 % Not the first trial
          % Move to beginning of trial 
          ind = BLOCKSIZE*sum(blocks(1:(i-1)));
          fseek(fid,ind,'bof');
       else
          ind = 0;
       end
       
       %%%%%%%%%%%%%%%%% Changed by ER on 07/26/04 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Get trial preamble
       % temp = g_read_preamble(fid,VSG_FLAG,USR_PREAMB_ELEMENTS);
       % THE ABOVE LINE HAS BEEN REMOVED AND REPLACED WITH THE BELOW SWTICH BLOCK
       
       switch (preamble_version)
       case {0,1,2}
           temp = g_read_preamble(fid,VSG_FLAG,USR_PREAMB_ELEMENTS);
       case {3,4}  % appends gain to the data structure
           temp = g_read_preamble2(fid,VSG_FLAG,USR_PREAMB_ELEMENTS);
       case {5,6}    % appends stimuli 17-26 to the data structure
           temp = g_read_preamble3(fid,VSG_FLAG,USR_PREAMB_ELEMENTS);
       otherwise
          error('This preamble version is not supported');
          return;
       end
       
       %%%%%%%%%%%%%%%%%%%%%%%%%% END ER CHANGE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
          
        
        
       % Pad the structure with a dummy variable so that
       % it can be passed directly to the dat structure.
       temp.eyedata = [];
       temp.statedata = [];
       temp.spkdata = [];
       % Store the original filename
       temp.fname = fname;
       temp.def = DEF;
       
       % Stuff into structure array
       dat(count) = temp;
	
       % Seek to end of preamble
       fseek(fid,ind+PREAMBLENGTH,'bof');
       
       % Get the eye data
       [dat(count).eyedata dat(count).statedata] = ...
          g_read_eyedata(...
			fid,...
			dat(count).NUMADC1,...
			dat(count).EYES,...
          dat(count).EYEGAIN,...
          dat(count).EYERES,...
          datatype_version);
	
       % If there are any spikes
       if dat(count).NUMSPIKE1 > 0
          % Get the spike data
          dat(count).spkdata = fread(fid,dat(count).NUMSPIKE1,'uint32');
          % Check for spike garbage
          if SPIKE_FLAG 
             % Checks for spike times greater than the recorded length of trial
             badspk = find(dat(count).spkdata > dat(count).TIME*1000);
             if ~isempty(badspk)
                % Keep only good spikes
                dat(count).spkdata = dat(count).spkdata(1:(badspk(1)-1));
                if DEBUG_FLAG
                   fprintf('%g pieces of spike garbage excluded from TRIAL # %g, TYPE - %s\n',...
                      dat(count).NUMSPIKE1 - (badspk(1)-1),dat(count).TRIAL,dat(count).TYPENAME);
                end
                % and update the number of spikes
                dat(count).NUMSPIKE1 = length(dat(count).spkdata);
             end
          end
       else
          % Or else return empty array
          dat(count).spkdata = [];
       end
       count = count + 1;
	end
catch
    fprintf('This is all the useful information the file has\n');
end

if nargout == 1
   fclose(fid);
end

if ERROR_FLAG  % Exclude all trials with positive ERROR field
   ind = find(extract(dat,'ERROR'));
   if DEBUG_FLAG
      for i = 1:length(ind)
         fprintf('TRIAL # %g excluded because ERROR high\n',dat(ind(i)).TRIAL);
      end
   end
   ind2 = ones(length(dat),1);
   ind2(ind) = 0;
   dat = dat(find(ind2));
end

return
