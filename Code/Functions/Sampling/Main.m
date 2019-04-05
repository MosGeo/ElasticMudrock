
nComponents = 3
nSamples  = 10000

samples = zeros(nSamples, nComponents);

for sampleNumber = 1:nSamples
   sample = zeros(1, nComponents);
   a=0; b = 1;
   for elementNumber = 1:nComponents
       sample(elementNumber) = (b-a).*rand(1,1) + a;
       b = 1 - sum(sample(1:elementNumber));
   end
   samples(sampleNumber,:)= sample(randperm(nComponents));
   %samples(sampleNumber,:)= sample; 
end

R = samples
figure('Color', 'White')
ternplot(samples(:,1), samples(:,2), samples(:,3), '.k')

    colors = rand(nSamples, nComponents)*(.6-.4)+.4;
    figure('Color', 'White')
    for i = 1:min(nSamples,1000)
        plot(R(i,:), 'Color', colors(i,:), 'LineWidth', .5); hold on;
    end
    plot(mean(R,1), 'k', 'LineWidth', 2)
    xlabel('Component Number');
    ylabel('Fraction')
    ylim([0 1])

%% Multinomial
n = 100
p = ones(nComponents,1)/ nComponents
samples = mnrnd(n,p, nSamples) / n

figure('Color', 'White')
ternplot(samples(:,1), samples(:,2), samples(:,3), '.')

%% Possible Combinations
[combinations, nCombinations] = getPossibleCombinations(nComponents, .01);
samples = combinations';

figure('Color', 'White')
ternplot(samples(:,1), samples(:,2), samples(:,3), '.')

%%
nSamples = 10000;
a = [1 1 1];


% Sample derichlet on simplex 
A = repmat(a, nSamples, 1);
B = 1;
r = gamrnd(A,1, [nSamples, numel(a)]);
r = r./sum(r,2);

ternplot(r(:,1), r(:,2), r(:,3), '.')


%%
nSamples = 10000;
nComponents = 3;

r = randCompositional(nComponents, nSamples, [1, 1, 1], false);

figure('Color', 'White')
ternplot(r(:,1), r(:,2), r(:,3), '.k')

figure('Color', 'White')
histogram(r(:,1)); hold on;
histogram(r(:,2)); hold on;
histogram(r(:,3)); hold on;

R=r
colors = rand(nSamples, nComponents)*(.6-.4)+.4;
figure('Color', 'White')
for i = 1:min(nSamples,1000)
    plot(R(i,:), 'Color', colors(i,:), 'LineWidth', .5); hold on;
end
plot(mean(R,1), 'k', 'LineWidth', 2)
xlabel('Component Number');
ylabel('Fraction')
ylim([0 1])


