% r101-r112 service time = 10
% r201-r211 service time = 10
% c101-c109 service time = 90
% c201-c208 service time = 90
% rc101-rc108 service time = 10
% rc201-rc208 service time = 10


st='rc'; 
for i = 201:208
    s = [st int2str(i)];
    data =  eval(s);
    xcoord = data(:,2);
    ycoord = data(:,3);
    lduedate = data(:,end-2);
    duedate = data(:,end-1);
    service = data(:, end);
    p = dist([xcoord' ; ycoord']);
%     p = p + 90 - 90*eye(101);

    diag_p = p(1, 2:end);
    p = p(2:end, 2:end) + diag(diag_p);
    p = p + 10 - 10*eye(100);

    duedate = duedate(2:end);
    lduedate = lduedate(2:end);

    csvwrite([s '/service.csv'], service);
    csvwrite([s '/duedate.csv'], duedate);
    csvwrite([s '/processingtime.csv'], p);

    save([s '/' s '.mat'],'p','lduedate','duedate')
end
