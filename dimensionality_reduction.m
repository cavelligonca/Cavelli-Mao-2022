function [signal_svd,eigenvalues]=dimensionality_reduction(signal,times,parameters)

inds=(times>=parameters.response(1) & times<=parameters.response(2));
indsbase=(times>=parameters.baseline(1) & times<=parameters.baseline(2));
[U,S]=svd(signal(:,inds));
eigenvalues=diag(S);
PCs=U'*signal;
vars=cumsum(eigenvalues.^2);
vars=100.*vars./vars(end);
max_dim=find(vars>=parameters.max_var,1,'first');
signal_svd=PCs(1:max_dim,:);
eigenvalues=eigenvalues(1:max_dim);
if parameters.min_snr>0
    snr=sqrt(mean(signal_svd(:,inds).^2,2)./mean(signal_svd(:,indsbase).^2,2));
    x=find(snr>parameters.min_snr);
    signal_svd=signal_svd(x,:);
    eigenvalues=eigenvalues(x);
end