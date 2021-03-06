classdef CheckupRoom < handle
    %CHECKUPROOM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        serviceRates;
        queue;
        busy;
        queueHistory;
        queueAverageSize;
        hospital;
    end
    
    properties (Access = private)
        elapsedTime
        boredPatientsCount
    end
    
    methods
        
        function obj = CheckupRoom(serviceRates)
            %CHECKUPROOM Construct an instance of this class
            %   Detailed explanation goes here
            obj.serviceRates = serviceRates;
            obj.queue = PriorityQueue();
            obj.busy = zeros(1, length(serviceRates));
            obj.queueHistory.time = {{0}, {0}, {0}};
            obj.queueHistory.lengths = {{0}, {0}, {0}};
            obj.boredPatientsCount = 0;
            obj.queueAverageSize = 0;
        end
        
        function sz = add(obj, patientId, hasCorona, time)
            % Returns number of free workers
            score = time;
            if (hasCorona == 1)
                score = -1 / time;
            end
            obj.changeQueueSize(hasCorona, time, 1);
            obj.queue.insert([score, time, patientId]);
            sz = length(obj.busy) - nnz(obj.busy);
        end
        
        function setHospital(obj, hospital)
            obj.hospital = hospital;
        end
        
        function [duration, success, patientId, workerId] = checkIn(obj, clock)
            % 1st: Duration to check
            % 2nd: is anyone to check
            % 3rd: patient to check
            % 4th: worker to check
            duration = 0;
            success = 0;
            patientId = 0;
            workerId = 0;
            if (obj.queue.size() == 0)
                return
            end
            freeWorkers = find(~obj.busy);
            
            if (isempty(freeWorkers))
                return
            end
            workerId = freeWorkers(randi(length(freeWorkers)));
            
            obj.busy(workerId) = 1;
            duration = exprnd(1/obj.serviceRates(workerId));
            success = 1;
            patientId = obj.queue.remove();
            patientId = patientId(3);
            if obj.hospital.patients{patientId}.status ~= Patient.BORED
                obj.changeQueueSize(obj.hospital.patients{patientId}.hasCorona, clock, -1);
            end
        end
        
        function free(obj, workerId)
            obj.busy(workerId) = 0;
        end
        
        function patientGetsBored(obj, hasCorona, clock)
            obj.boredPatientsCount = obj.boredPatientsCount + 1;            
            obj.changeQueueSize(hasCorona, clock, -1);
        end
        
        function sz = length(obj)
            sz = obj.queue.size();
        end
        
        function addToHistory(obj, id, clock, len)
            % add time and length of queue at time clock to history for
            % plotting
            if (length(obj.queueHistory.time{id}) >= 1 && obj.queueHistory.time{id}{end} == clock && obj.queueHistory.lengths{id}{end} == len)
                % dont add
            elseif (length(obj.queueHistory.time{id}) >= 2 && obj.queueHistory.time{id}{end-1} == clock && obj.queueHistory.lengths{id}{end-1} == len)
                obj.queueHistory.time{id}(end) = [];
                obj.queueHistory.lengths{id}(end) = [];
            elseif (length(obj.queueHistory.time{id}) >= 2 && obj.queueHistory.time{id}{end-1} == clock)
                obj.queueHistory.time{id}{end} = clock;
                obj.queueHistory.lengths{id}{end} = len;
            else
                obj.queueHistory.time{id}{end+1} = clock;
                obj.queueHistory.lengths{id}{end+1} = len;
            end
        end
    end
    
    methods (Access = private)
        
        
        
        function changeQueueSize(obj, hasCorona, clock, diff)
            lastLength = obj.queueHistory.lengths{1}{end};
            obj.addToHistory(1, clock, lastLength);
            obj.addToHistory(1, clock, lastLength + diff);
            
            if hasCorona
                lastLength = obj.queueHistory.lengths{2}{end};
                obj.addToHistory(2, clock, lastLength);
                obj.addToHistory(2, clock, lastLength + diff);
            else
                lastLength = obj.queueHistory.lengths{3}{end};
                obj.addToHistory(3, clock, lastLength);
                obj.addToHistory(3, clock, lastLength + diff);    
            end
        end
    end
end

