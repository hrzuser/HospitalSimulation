function outputServingTimeHistogram(hospital)
    results.infected_servingtime = {};
    results.healthy_servingtime = {};
    results.all_servingtime = {};
    for i = 1 : length(hospital.patients)
       if hospital.patients{i}.status == Patient.BORED
           continue;
       end
       if hospital.patients{i}.hasCorona
           results.infected_servingtime{end+1} = hospital.patients{i}.timeInSystem - hospital.patients{i}.timeInQueue;
       else
           results.healthy_servingtime{end+1} = hospital.patients{i}.timeInSystem - hospital.patients{i}.timeInQueue;
       end
       results.all_servingtime{end+1} = hospital.patients{i}.timeInSystem - hospital.patients{i}.timeInQueue;
    end
    subplot(3, 1, 1);
    X = cell2mat(results.all_servingtime);
    h1 = histogram(X);
    title("serving time for all");
    %hold on;
    subplot(3, 1, 2);
    h2 = histogram(cell2mat(results.infected_servingtime));
    
    title("serving time for infected");
    %hold on;
    subplot(3, 1, 3);
    h3 = histogram(cell2mat(results.healthy_servingtime));
    title("serving time for healthy");
    %hold on;
end