ENTER_HOSPITAL = 0;
CHECKIN = 1;
ASSIGN_ROOM = 2;
ENTER_ROOM = 3;
CHECKUP = 4;
EXIT_HOSPITAL = 5;
GOT_BORED = 6;




disp('-------Hospital Simulation-------');
disp('Please Enter M/lambda/alpha/mu');
M = 1; % input('Enter M (The number of rooms): ');
lambda = 1; % input('Enter lambda (Average patients arrival): ');
alpha = 1; % input('Enter alpha (Average time of patients fatigue): ');
mu = 1; % input('Enter mu (The service rate of reception): ');
    
hospital.reception = CheckupRoom(mu);

hospital.rooms = {};
for i = 1:M
    rates = [1, 2]; % input('Enter service rates of room as a vector: ')
    hospital.rooms{i} = CheckupRoom(rates);
end

clock = 0;
E = PriorityQueue(1);
% Events pattern: [time, type, patientId, roomId, workerId]

patient_count = 1; % input('Enter the number of patients: ');
T_accumulated = 0;
for i = 1:patient_count
    dt = exprnd(1/lambda);
    T_accumulated = T_accumulated + dt;
    entrance_event = [T_accumulated, ENTER_HOSPITAL, i, -1, -1];
    E.insert(entrance_event);
    bored_event = [T_accumulated + exprnd(1/alpha), GOT_BORED, i, -1, -1];
    E.insert(bored_event);
    hospital.patients{i} = Patient();
end


while (E.size() > 0)
    event = E.remove();
    clock = event(1);
    type = event(2);
    patientId = event(3);
    roomId = event(4);
    disp(event);
    switch type
        case ENTER_HOSPITAL
            disp('Enter Hospital');
            patient = hospital.patients{patientId};
            patient.enterHospital(clock);
            if (hospital.reception.add(patientId, patient.hasCorona, clock) > 0)
                % Start checkin if possible
                E.insert([clock, CHECKIN, -1, -1, -1]);
            end
        case CHECKIN
            disp('Checkin');
            [duration, success, patientId, workerId] = hospital.reception.checkIn(clock);
            if (success == 1)
                E.insert([clock + duration, ASSIGN_ROOM, patientId, -1, -1])
            end
        case ASSIGN_ROOM
            disp('Assign room');
            
            % Find best room
            cnt = 1;
            bestRoomIds = {1};
            for i = 2:M
                bestRoomScore = hospital.rooms{bestRoomIds{1}}.length();
                thisRoomScore = hospital.rooms{i}.length();
                if (bestRoom_score < thisRoomScore)
                    bestRoomIds = {};
                    cnt = 0;
                end
                bestRoomIds{cnt} = i;
                cnt = cnt + 1;
            end
            bestRoomId = bestRoomIds{randi(cnt)};
            
            % Free reception worker
            hospital.reception.free(1);
            E.insert([clock, CHECKIN, -1, -1, -1]);
            
            % Enter patient to room
            E.insert([clock, ENTER_ROOM, patientId, bestRoomId, -1])
        case ENTER_ROOM
            disp('Move to room queue');
            disp(patientId);
            patient = hospital.patients{patientId};
            patient.enterRoom(clock);
            room = hospital.rooms{roomId};
            if (room.add(patientId, patient.hasCorona, clock) > 0)
                E.insert([clock, CHECKUP, -1, roomId, -1])
            end
        case CHECKUP
            disp('Checkup patient');
            room = hospital.rooms{roomId};
            [duration, success, patientId, workerId] = room.checkIn(clock);
            patient = hospital.patients{patientId};
            patient.checkup(clock);
            disp(patientId);
            if (success == 1)
                E.insert([clock + duration, EXIT_HOSPITAL, patientId, -1, -1]);
            end
        case EXIT_HOSPITAL
            disp('Leaveing happy');
            patient = hospital.patients{patientId};
            patient.exitHospital(clock);
        case GOT_BORED
            patient = hospital.patients{patientId};
            if (patient.status == Patient.IN_RECEPTION_QUEUE)
                disp('Leaveing sad'); 
                hospital.reception.patientGetsBored(clock, patientId); 
                patient.bored(clock);
            end
    end
end