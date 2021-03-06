function outputNumberOfPatientsInSystem(hospital)
    qq = PriorityQueue();

    for i = 1 : length(hospital.patients)
        % handle number of patients in system plot
        qq.insert([hospital.patients{i}.beginTimeInSystem, 1, hospital.patients{i}.hasCorona]);
        qq.insert([hospital.patients{i}.beginTimeInSystem + hospital.patients{i}.timeInSystem, -1, hospital.patients{i}.hasCorona]);
    end

    results.numberInSystemPlot.X = {{0}, {0}, {0}};
    results.numberInSystemPlot.Y = {{0}, {0}, {0}};

    while qq.size() > 0
        pk = qq.peek();
        qq.remove();
        for type = 1:3
            if type == 1 || (3 - type == pk(3))
                results.numberInSystemPlot.X{type}{end+1} = pk(1);
                results.numberInSystemPlot.Y{type}{end+1} = results.numberInSystemPlot.Y{type}{end};
                results.numberInSystemPlot.X{type}{end+1} = pk(1);
                ad = pk(2);
                results.numberInSystemPlot.Y{type}{end+1} = results.numberInSystemPlot.Y{type}{end} + ad;
            end 
        end
    end
    
    res = {' (general)', ' (infected)', ' (healthy)'};
    for d = 1:3
        subplot(3, 1, d);
        results.numberInSystemPlot.X{d} = cell2mat(results.numberInSystemPlot.X{d});
        results.numberInSystemPlot.Y{d} = cell2mat(results.numberInSystemPlot.Y{d});
        plot(results.numberInSystemPlot.X{d}, results.numberInSystemPlot.Y{d}), xlabel("time"), ylabel("number of patients in system"), title(strcat("number of patients in system", res{d}));
    end
end