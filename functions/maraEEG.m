%% Function: maraEEG(subject_start, subject_end, subjects, workdir)
% Author: Will Decker
% Usage: run MARA to identify and remove artifacts/bad components
% Inputs 
    % subject_start: subject file to start loading (the position of the file name in subject_names
    % subject_end: last subject file to load (the position of the file name in subject_names
    % subjects: a str list of subject names to be loaded into the EEG object
    % workdir: path to working directory
    % threshold: probabilty that an artifact is a true artifact


%%
function [EEG, com] = maraEEG(subject_start, subject_end, subjects, workdir, threshold)

EEG = [];
com = ' ';

for s = subject_start : subject_end
    subject = subjects{s};

% establish data objects
[ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;
eeglab('redraw');

% load ICA set
EEG = pop_loadset ([subject '_ICA.set'], workdir);
[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );

% run MARA and identify components
[ALLEEG, EEG, EEG.reject.gcompreject ] = processMARA (ALLEEG, EEG,CURRENTSET) ;

% remove components greater than or equal to probability threshold
remove_components = EEG.reject.MARAinfo.posterior_artefactprob(1:10) >= threshold;
EEG = pop_subcomp( EEG, find(remove_components), 0);
[ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'setname',[subject '_MARA'],'gui','off');
EEG = eeg_checkset( EEG );

% save new dataset
EEG = eeg_checkset( EEG ) ;
[ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET ) ;
EEG = pop_saveset( EEG, [subject '_MARA'], workdir);

end