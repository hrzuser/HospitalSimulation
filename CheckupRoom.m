classdef CheckupRoom < handle
    %CHECKUPROOM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        serviceRates;
        queue;
        busy;
        queueHistory;
    end
    
    properties (Access = private)
        boredPatientsCount
    end
    
    methods
        function obj = CheckupRoom(serviceRates)
            %CHECKUPROOM Construct an instance of this class
            %   Detailed explanation goes here
            obj.serviceRates = serviceRates;
            obj.queue = PriorityQueue();
            obj.busy = zeros(1, length(serviceRates));
            obj.queueHistory.time = zeros(1);
            obj.queueHistory.lengths = zeros(1);
            obj.boredPatientsCount = 0;
        end
        
        function sz = add(obj, patientId, hasCorona, time)
            % Returns number of free workers
            score = time;
            if (hasCorona == 1)
                score = -1 / time;
            end
            obj.changeQueueSize(time, 1);
            obj.queue.insert([score, time, patientId]);
            sz = length(obj.busy) - nnz(obj.busy);
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
            disp('DEBUG3: ------------------------------')
            disp(freeWorkers);
            disp(obj.busy);
            if (isempty(freeWorkers))
                return
            end
            workerId = freeWorkers(randi(length(freeWorkers)));
            disp('DEBUG: ------------------------------')
            disp(workerId);
            obj.busy(workerId) = 1;
            duration = poissrnd(obj.serviceRates(workerId));
            success = 1;
            patientId = obj.queue.remove();
            obj.changeQueueSize(clock, -1);
            patientId = patientId(3);
        end
        
        function free(obj, workerId)
            obj.busy(workerId) = 0;
        end
        
        function patientGetsBored(obj, clock)
            obj.boredPatientsCount = obj.boredPatientsCount + 1;            
            obj.changeQueueSize(clock, -1);
        end
        
        function sz = length(obj)
            sz = obj.queue.size();
        end
    end
    
    methods (Access = private)
        function addToHistory(obj, clock, len)
            % add time and length of queue at time clock to history for
            % plotting
            obj.queueHistory.time = [obj.queueHistory.time, clock];
            obj.queueHistory.lengths = [obj.queueHistory.lengths, len];    
        end
        
        
        function changeQueueSize(obj, clock, diff)
            lastLength = obj.queueHistory.lengths(length(obj.queueHistory.lengths));
            obj.addToHistory(clock, lastLength);
            obj.addToHistory(clock, lastLength + diff);
        end
    end
end

