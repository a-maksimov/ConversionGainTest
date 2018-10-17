% General example of an *IDN? query
% Make sure you have installed NI VISA 15.0 or newer with .NET support
% This example does not require MATLAB Instrument Control Toolbox
% It is based on using .NET assembly called Ivi.Visa
% that is istalled together with NI VISA

clear;
close all;
clc;

try 
    assemblyCheck = NET.addAssembly('Ivi.Visa');
catch
    error('Error loading .NET assembly Ivi.Visa');
end

resourceString1 = 'TCPIP::192.168.1.69::INSTR'; % Standard LAN connection (also called VXI-11)
resourceString2 = 'TCPIP::192.168.1.69::hislip0'; % Hi-Speed LAN connection - see 1MA208
resourceString3 = 'GPIB::20::INSTR'; % GPIB Connection
resourceString4 = 'USB::0x0AAD::0x0119::022019943::INSTR'; % USB-TMC (Test and Measurement Class)

% Opening VISA session to the instrument
scope = Ivi.Visa.GlobalResourceManager.Open( resourceString1 );
scope.Clear()
% LineFeed character at the end
scope.RawIO.Write(['*IDN?' char(10)]); 
idnResponse = char(scope.RawIO.ReadString());

msgbox(sprintf('Hello, I am\n%s', idnResponse));