function [] = QBI_send_trigger(trg_id, ioObj, port_address)
% this function sends the trigger 'id', and writes the event to the trigger
% log file (defined in run_forage_task.m)

% trg_id     = a single trigger value (integer)
% ioObj      = trigger function 
% port_address = port address for triggers


% send the trigger
io64(ioObj, port_address, trg_id);
WaitSecs(.003); % wait 3 msec
io64(ioObj, port_address, 0); % set to low again

end