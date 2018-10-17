function cs = CRC6(data,nb)
%  data - указатель на пятый байт пакета
%  nb  - длинна пакета минус 4
    cs = uint8(0);
    for i = 1:uint8(nb)
    cst = uint8(hex2dec(data(i)));
        for j = 1:8
            cs = bitsrl(cs,1);
            if bitand(bitxor(bitsll(cs,6),bitsll(cst,7)),uint8(128),'uint8') ~= 0
                cs = bitxor(cs,uint8(hex2dec('C2')));
            end
            cst = bitsrl(cst,1);
        end
    end
    cs = bitsrl(cs,2);
    % dec2hex(cs,2)
    cs = dec2bin(cs,6);
end