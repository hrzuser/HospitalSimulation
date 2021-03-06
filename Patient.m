classdef Patient < handle
    %PARIENT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        status
        hasCorona
        timeInSystem
        timeInQueue
        boredDuration
        boredTime
        beginTimeInSystem
    end
    
    properties (Access = private)
        % last event time saved:
        lastEventTime
    end
    
    properties (Constant)
      % status mapping:
      IN_RECEPTION_QUEUE = 1;
      DURING_CHECKIN = 2;
      IN_ROOM_QUEUE = 3;
      DURING_CHECKUP = 4;
      NOT_IN_HOSPITAL = 5;
      BORED = 6;
    end
    
    methods
        function obj = Patient(boredDuration, clock)
            obj.status = Patient.NOT_IN_HOSPITAL;
            obj.hasCorona = rand(1, 1) > 0.9;
            obj.timeInSystem = 0;
            obj.timeInQueue = 0;
            obj.lastEventTime = 0;
            obj.boredDuration = boredDuration;
            obj.boredTime = clock + boredDuration;
        end
         
        function enterHospital(obj, clock)
            obj.elapseTime(clock);
            obj.status = Patient.IN_RECEPTION_QUEUE;
            obj.beginTimeInSystem = clock;
        end
        
        function checkin(obj, clock)
            obj.elapseTime(clock);
            obj.status = Patient.DURING_CHECKIN;
        end
        
        function enterRoom(obj, clock)
            obj.elapseTime(clock);
            obj.status = Patient.IN_ROOM_QUEUE;
        end
        
        function checkup(obj, clock)
            obj.elapseTime(clock);
            obj.status = Patient.DURING_CHECKUP;
        end
        
        function exitHospital(obj, clock)
            obj.elapseTime(clock);
            obj.status = Patient.NOT_IN_HOSPITAL;
        end
        
        function bored(obj, clock)
            % event getting bored
            obj.elapseTime(clock);
            obj.status = Patient.BORED;
        end
        
        function renewBoredTime(obj, clock)
            obj.boredTime = obj.boredDuration - obj.timeInQueue + clock;
        end
        
    end
    
    methods (Access = private)
        function elapseTime(obj, clock)
            % change properties when time passes
            deltaTime = clock - obj.lastEventTime;
            switch obj.status
                case Patient.IN_RECEPTION_QUEUE
                    obj.timeInSystem = obj.timeInSystem + deltaTime;
                    obj.timeInQueue = obj.timeInQueue + deltaTime;
                case Patient.IN_ROOM_QUEUE
                    obj.timeInSystem = obj.timeInSystem + deltaTime;
                    obj.timeInQueue = obj.timeInQueue + deltaTime;
                case Patient.DURING_CHECKUP
                    obj.timeInSystem = obj.timeInSystem + deltaTime;
                case Patient.BORED
                    obj.timeInSystem = obj.timeInSystem + deltaTime;
            end
            obj.lastEventTime = clock;
        end
    end
end

