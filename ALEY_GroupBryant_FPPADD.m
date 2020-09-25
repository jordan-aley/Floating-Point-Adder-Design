function y = ALEY_GroupBryant_FPADD()

%Create input and output file
input_file = fopen('ALEY_GroupBryant_FPADD_input.txt', 'w');
output_file = fopen('ALEY_GroupBryant_FPADD_VENDOR_output.txt', 'w');
output_file2 = fopen('ALEY_GroupBryant_FPADD_ADDCORE_output.txt', 'w');

%X padding for input
for i = 1:2
fprintf(input_file, 'X X X XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\n');
end

%X padding output vendor
for i = 1:10
 fprintf(output_file, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX X\n');
end

%X padding output addcore
for i = 1:15
 fprintf(output_file2, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX X\n');
end

format long g

x1 = -29+(29-(-29))*rand(100,1)
x2 = -29+(29-(-29))*rand(100,1)
x3 = x1 + x2
EnR = '1';
EnL = '1';
Reset = '0';


for i = 1:length(x1)
    
    y2 = sprintf('%tx', x1(i));
    
    h1 = strread(y2,  '%2s', 'delimiter', '');
    
    b1 = dec2bin(hex2dec(h1),8);
    
    S1(i, 1:32) = reshape(b1.',1,[]);
      
    
    y2 = sprintf('%tx', x2(i));
    
    h2 = strread(y2,  '%2s', 'delimiter', '');
    
    b2 = dec2bin(hex2dec(h2),8);
    
    S2(i, 1:32) = reshape(b2.',1,[]);
    
    
    y3 = sprintf('%tx', x3(i));
    
    h3 = strread(y3,  '%2s', 'delimiter', '');
    
    b3 = dec2bin(hex2dec(h3),8);
    
    S3(i, 1:32) = reshape(b3.',1,[]);
    
    input = [Reset ' ' EnR ' ' EnL ' ' ((S1(i,1:32))) ' ' ((S2(i,1:32)))];
    output = ((S3(i,1:32)));
    
    %fprintf(file1, '%f\r\n', x1, x2);
    fprintf(input_file, '%s\r\n', input);
    fprintf(output_file, '%s\r\n', [output ' ' '1']);
    fprintf(output_file2, '%s\r\n', [output ' ' '1']);
    
end

fprintf(output_file, '.\n');
fprintf(output_file2, '.\n');
fprintf(input_file, '.\n');
fclose('all');
end
