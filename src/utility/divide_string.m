function  [name num] = divide_string(data)
name = sscanf(data,'%s$');
name_len = length(name);
total_len = length(data);
leave_part = data(name_len+2:total_len-1);
%num = sscanf(leave_part, '%f');
num = leave_part;
end

