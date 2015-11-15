function [result, means] = kmeansClustering(x, K, threshold)
% Input
% x ... input data as matrix
%       each row represents one point
%       each coloum represents one dimention of the datapoints, e.g. rgb
% k ... number of clusters
% threshold ... threshold for stopping iterations

% Output
% result ... cluster labels
% means ... final centroids of calculations

dim = size(x, 2);
N = size(x, 1);
ratio = Inf;
labels = zeros(N, K);



% create random meanvalues
% rng(12345678);
% centroids = rand(K, dim)

% choose random unique datapoints as centroids instead
% rng(123456788);                 % init generator with seed
r = randperm(N);
r = r(1:K);
centroids = x(r, :);            % choose unique random rows from datamatrix

disp(sprintf('### K-Means for %d clusters and threshold %d ###', K, threshold));

iterations = 1;
Jold = 999999;
ratio = 99999;
while(ratio > threshold)
    disp(sprintf('--> Iteration: %d', iterations));

    % assign nearest centroid
    labels = zeros(N, K);
    for n = 1:1:N                                     % For every datapoint
        minDist = Inf;
        nearestCentroid = 0;
        for k = 1:1:K                                   % check each centroid
            tmpdist = norm(x(n, :) - centroids(k, :))^2;% calc dist
            if(tmpdist < minDist)                       % and find minimum
                minDist = tmpdist;
                nearestCentroid = k;
            end
        end
        labels(n, nearestCentroid) = 1;               % (all 0 except 1 per row)
    end
    
    
    % calc new centroids according to new labels of datapoints
    for k = 1:1:K                                       % for all centroids
        sumPointsInCluster = zeros(1, dim);
        for j = 1:1:dim                                 % and each dim
            % add values to sum
            sumPointsInCluster(1, j) = sumPointsInCluster(1, j) + sum(labels(:, k) .* x(:, j));
        end
        % calc mean per centroid
        centroids(k, :) = sumPointsInCluster ./ sum(labels(:, k));
    end
    
    
    % calc J
    Jnew = 0;
    for n = 1:1:N
        for k = 1:1:K
            Jnew = Jnew + labels(n, k) * norm(x(n, :) - centroids(k, :))^2;
        end
    end
    ratio = Jold / Jnew;
    disp(sprintf('ratio: %d (J_old: %d, J_new: %d)', ratio, Jold, Jnew));
    Jold = Jnew;
    iterations = iterations + 1;
end

result = labels;
means = centroids;
end




