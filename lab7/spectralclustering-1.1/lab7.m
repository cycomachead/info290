load X;

%% question 2
A = gen_nnd(X, 7, 500);
[clusters, evals] = sc(A, 0, 2);

%% question 3
scatter(X(:,1), X(:,2), 5, clusters);

%% question 4
% No, it did not!
evals

%% question 5
k_heuristic = ceil(log(size(X, 1)));
for i = -5:5
    runexpl2(X, 2, k_heuristic + i);
    disp(k_heuristic + i);
    pause;
end

% 7 + 2 = 9 seems to be optimal

%% question 6
[x1,y1] = randr(50, 5000, 0.10);
[x2,y2] = randr(20, 4000, 0.05);
x = [x1 x2]';
y = [y1 y2]';
X2 = [x y];
scatter(x,y);

%% question 7