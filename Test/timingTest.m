clear all;
clc;

DSim=dsim.DSim.getInstance();
Agent=dsim.Agent();
DSim.addAgent(Agent);

DSim.run(5);
