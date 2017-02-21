%function [localDistance,Entropy,FM,AM,Pitch,PGoodness]=local_dist(localDist,mindur)
function [distance,feature_diffs]=calculateDistance(DistMatrix,mindur,YNfeature_diffs,Entropy_dist,AM_dist,FM_dist,Pitch_dist,PGood_dist)

%% initialize
count=0;
DistMsize=size(DistMatrix);
ds1=DistMsize(1);
ds2=DistMsize(2);
mindim=min(ds1,ds2);
distmins=zeros(mindim,1);

Entropy=zeros(mindim,1);
FM=zeros(mindim,1);
AM=zeros(mindim,1);
Pitch=zeros(mindim,1);
PGoodness=zeros(mindim,1);

%% main for loop for mindur/tolerance
for k=1:mindim%length(diag(localDist));
    maxIl_1=min(ds1,mindim);
    maxIl_2=min(ds2,mindim);
    max_indices=k:k+mindur-1;
    %     mat_chunk=[k:k+mindur-1];
    
    if maxIl_1 >= max_indices & maxIl_2 >= max_indices %ok, proceed
        m=DistMatrix(k:k+mindur-1,k:k+mindur-1);
        matchunk_a=k:k+mindur-1;matchunk_b=k:k+mindur-1;
        count=count+1;
    elseif maxIl_1 >= max_indices & maxIl_2 <= max_indices
        m=DistMatrix(k:k+mindur-1,k:maxIl_2)
        count=count+1;
        matchunk_a=[k:k+mindur-1]; matchunk_b=[k:maxIl_2];
    elseif maxIl_1 <= max_indices & maxIl_2 >= max_indices
        m=DistMatrix(k:maxIl_1,k:k+mindur-1);
        count=count+1;
        matchunk_a=[k:maxIl_1]; matchunk_b=[k:k+mindur-1];
    else
        m=DistMatrix(k:mindim,k:mindim);
        count=count+1;
        matchunk_a=[k:mindim]; matchunk_b=[k:mindim];
    end
    
    % calculates minimum distance within mindur (default: 9 windows)
    meanDist=[];
    
    for t=-mindur:mindur;
        diagonal=diag(m,t);
        distDiag=mean(diag(m,t));
        if size(distDiag,1)<size(distDiag,2);
            distDiag=nanmean(distDiag,2);
        end
        if k==length(diag(DistMatrix))%end
            distDiag=m(1,1);
        end
        meanDist=[meanDist; distDiag];
    end %calculates tolerance
    [minDist, ILD]=min(meanDist);
    distmins(count)=mean(minDist);
    distance=mean(distmins);
    
    %return index of min diagonal for feature
    tolsLD=-mindur:mindur;
    tolILD=tolsLD(ILD);
    
    if YNfeature_diffs==1 %calculate differences for individual features
        %feature measurements...
        
    
        Entropy_diff=nanmean(mean(diag(Entropy_dist(matchunk_a, matchunk_b),tolILD)));
        AM_diff=nanmean(mean(diag(AM_dist(matchunk_a, matchunk_b),tolILD)));
        FM_diff=nanmean(mean(diag(FM_dist(matchunk_a, matchunk_b),tolILD)));
        Pitch_diff=nanmean(mean(diag(Pitch_dist(matchunk_a, matchunk_b),tolILD)));
        PGood_diff=nanmean(mean(diag(PGood_dist(matchunk_a, matchunk_b),tolILD)));
        
        Entropy(count)=Entropy_diff;
        AM(count)=AM_diff;
        FM(count)=FM_diff;
        Pitch(count)=Pitch_diff;
        PGood(count)=PGood_diff;
          
    else YNfeature_diffs==0;
        Entropy(count)=0;
        AM(count)=0;
        FM(count)=0;
        Pitch(count)=0;
        PGood(count)=0;
    end
end

    Entropy=nanmean(Entropy);
    AM=nanmean(AM);
    FM=nanmean(FM);
    Pitch=nanmean(Pitch);
    PGood=nanmean(PGood);
    
    feature_diffs={Entropy,AM,FM,Pitch,PGood};

end

