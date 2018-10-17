function byteBuf(s,c)
	byte(1:23) = {'00'};
	byte{1} = '55';
	byte{2} = '55';
	byte{3} = '40';
    byte{4} = '00';
	byte{14} = dec2hex(bin2dec('00000000'),2); % 8, 7 Вкл/Выкл режим АК, 6 Reset МПП Вкл/Выкл УМ, 5-1 Установка аттенюатора (дБ) 
	byte{15} = dec2hex(bin2dec(strcat('0',dec2bin(c,7))),2); % 8 Вкл/Выкл вентиляторов, 7-1 Рабочая частота (№ волны)
    data = byte(5:length(byte));
    crc = CRC6(data,length(byte)-4);
    byte{4} = dec2hex(bin2dec(strcat(crc,'01')),2); % 8-3 CRC-6, 2,1 Номер МПП
	for i = 1:length(byte)
        fwrite(s,hex2dec(byte(i)),'uint8')
	end
end