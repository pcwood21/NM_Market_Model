clear all

DSim=dsim.DSim.getInstance();

server=dsim.Server();
DSim.addAgent(server);

mgmtServer=dsim.MgmtServer();
mgmtServer.targetServer=server.id;
DSim.addAgent(mgmtServer);

for i=1:100
client=dsim.Client();
client.managementServer=mgmtServer.id;
DSim.addAgent(client);
end

for i=1:10
    attacker=dsim.Attacker();
    attacker.managementServer=mgmtServer.id;
    attacker.attackStartTime=10;
    DSim.addAgent(attacker);
end

logger=dsim.Logger();
DSim.addAgent(logger);


DSim.run(60*1);

