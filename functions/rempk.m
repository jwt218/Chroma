function [DF] = rempk(DF,t1,t2)

DFk = DF.X.M(:,1);
rmi = find(DFk(:,1) >= t1 & DFk(:,1) <= t2);
DF.X.M(rmi,:) = NaN;


end
