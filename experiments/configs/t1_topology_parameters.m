function p = t1_topology_parameters()
%T1_TOPOLOGY_PARAMETERS Source-labelled parameters for the T1 reconstructions.
% Rows are controlled-coordinate derivative blocks, not completed Hessians.
% Paper notation is J_j^i (agent i, objective j); state order is documented
% separately for each example.

p.notation = 'J_j^i: superscript i is agent, subscript j is objective';

% Thesis Example 2.9 (paper literal signs), x=[x^1;x^2;x^3].
% Agent i controls scalar x^i and has two objectives.
c.name = 'TOP-C paper Example 2.9';
c.source = 'thesis Example 2.9, Figure 2.3';
c.stateOrder = {'x^1','x^2','x^3'};
c.objectiveOrder = {'J_1^1','J_2^1','J_1^2','J_2^2','J_1^3','J_2^3'};
c.ownRows = zeros(3,3,2);
c.ownRows(1,:,1)=[-1,0,0.4]; c.ownRows(1,:,2)=[-1,0,-0.6];
c.ownRows(2,:,1)=[1,-2,0.4]; c.ownRows(2,:,2)=[1,-2,-0.5];
c.ownRows(3,:,1)=[0,0,-1.5]; c.ownRows(3,:,2)=[0,0,-1];
c.ownOffsets = [0,5;0,6;0,-10];
c.weightMeaning = 'w_i multiplies J_1^i; 1-w_i multiplies J_2^i';
c.legacyOwnRows = c.ownRows;
c.legacyOwnRows(1,:,2)=[-1,0,0.6];
c.legacyOwnRows(2,:,2)=[1,-2,0.5];
c.legacyNote = ['acc2024/cube uses +0.6/+0.5 and fixes M to objective-1 rows; ' ...
    'the T1 reconstruction uses paper signs and weights both M and b'];
p.cube = c;

% Thesis Example 2.10 (paper literal signs), x=[x_1^1;x_2^1;x^2].
% Agent 1 controls two coordinates and has three objectives; agent 2 controls
% one coordinate and has two objectives.
q.name = 'TOP-P paper Example 2.10';
q.source = 'thesis Example 2.10, Figure 2.4';
q.stateOrder = {'x_1^1','x_2^1','x^2'};
q.objectiveOrder = {'J_1^1','J_2^1','J_3^1','J_1^2','J_2^2'};
q.agent1Blocks = zeros(2,3,3);
q.agent1Blocks(:,:,1)=[-1,0,0.5;0,-1,0];
q.agent1Blocks(:,:,2)=[-1,0,0.5;0,-2,0];
q.agent1Blocks(:,:,3)=[-1,0,0;0,-2,0.5];
q.agent1Offsets = [0,0;0,5;6,0]';
q.agent2Rows = [-1,0.5,-2;-1,0.5,-2];
q.agent2Offsets = [0,6];
q.weightMeaning = ['lambda=(lambda_1,lambda_2,lambda_3) weights agent 1 objectives; ' ...
    'q weights J_1^2 and 1-q weights J_2^2'];
q.legacyAgent2Rows = [1,0.5,-2;1,0.5,-2];
q.legacyNote = ['acc2024/triangular prism uses +1 as the first coefficient of both ' ...
    'agent-2 rows; it does weight both M and b'];
p.prism = q;

% Thesis Example 2.11. These are complete scalar formulas, not an own-row
% completion: profit and environmental objectives are stated explicitly.
a.name = 'production and pollution control, Example 2.11';
a.source = 'thesis Example 2.11, Figure 2.5';
a.stateOrder = {'x^1 production','x^2 production'};
a.formulas = { ...
    'J_1^1=(100-2(x^1+x^2))x^1-5(x^1)^2', ...
    'J_2^1=150-3(x^1)^2', ...
    'J_1^2=(100-2(x^1+x^2))x^2-4(x^2)^2', ...
    'J_2^2=140-2.5(x^2)^2'};
p.application = a;

p.nonlinear.status = 'schematic only';
p.nonlinear.source = ['thesis Figure 2.6 gives no complete functions or numerical ' ...
    'parameters; T1 draws only a labelled conceptual diagram'];
end
