function Y = GibbsSampler(X, Y, K)
N = size(X, 2);
D = size(X, 1);

% t = cputime

N_k = [];
S_k = zeros(K, D, D);
Sum_k = [];
for i = 1: K
	X_k = X(:, Y == i);
	N_k = [N_k size(X_k, 2)];
	S_k(i, :, :) = X_k * X_k';
	Sum_k = [Sum_k sum(X_k, 2)];
end

alpha = K;

for i = 1: N
    x_i = X(:, i);
    
    q = zeros(1, K);
    for k = 1: K
        if k == Y(1, i)
            q(1, k) = (N_k(1, k) - 1 + (alpha / K)) / (N + alpha - 1);
        else
        	q(1, k) = (N_k(1, k) - 1 + (alpha / K)) / (N + alpha - 1);
        end
    end
    q = q / sum(q);
    
	tmp = rand;
    for k = 1: size(q, 2)
		tmp = tmp - q(1, k);
		if tmp <= 0
			new_k = k;
			break;
		end
    end
    
    k = Y(1, i);
    
    if new_k == k
        kappa_0 = 0.01;
        v_0 = D + 2;
        m_0 = Sum_k(:, k) / N_k(1, k);
        X_k = X(:, Y == k);
        S_0 = diag(diag((X_k - repmat(m_0, [1, size(X_k, 2)])) * (X_k - repmat(m_0, [1, size(X_k, 2)]))')) / N_k(1, k);
        
        n = N_k(1, k);
		kappa_n = kappa_0 + n;
		v_n = v_0 + n;
		m_n = (kappa_0 * m_0 + Sum_k(:, k)) / kappa_n;
		S_ni = S_0 + squeeze(S_k(k, :, :)) + kappa_0 * (m_0 * m_0') - kappa_n * (m_n * m_n');
		m_n = (kappa_0 * m_0 + Sum_k(:, k) - x_i) / (kappa_n - 1);
		S_n = S_0 + squeeze(S_k(k, :, :)) - x_i * x_i' + kappa_0 * (m_0 * m_0') - (kappa_n - 1) * (m_n * m_n');

        p = GIW(kappa_n, v_n, S_ni, S_n, x_i) * (n - 1 + (alpha / K)) / (N + alpha - 1);
        
        k = new_k;
        kappa_0 = 0.01;
        v_0 = D + 2;
        m_0 = Sum_k(:, k) / N_k(1, k);
        X_k = X(:, Y == k);
        S_0 = diag(diag((X_k - repmat(m_0, [1, size(X_k, 2)])) * (X_k - repmat(m_0, [1, size(X_k, 2)]))')) / N_k(1, k);
        
        n = N_k(1, k);
		kappa_n = kappa_0 + n;
		v_n = v_0 + n;
		m_n = (kappa_0 * m_0 + Sum_k(:, k)) / kappa_n;
		S_ni = S_0 + squeeze(S_k(k, :, :)) + kappa_0 * (m_0 * m_0') - kappa_n * (m_n * m_n');
		m_n = (kappa_0 * m_0 + Sum_k(:, k) - x_i) / (kappa_n - 1);
		S_n = S_0 + squeeze(S_k(k, :, :)) - x_i * x_i' + kappa_0 * (m_0 * m_0') - (kappa_n - 1) * (m_n * m_n');

        new_p = GIW(kappa_n, v_n, S_ni, S_n, x_i) * (n - 1 + (alpha / K)) / (N + alpha - 1);
        k = Y(1, i);
        
		% Evaluate r = min{1,p(yi = new_k | rest) / p(yi = k|rest) * q(k) / q(new_k)}
        r = 1;
    else
        kappa_0 = 0.01;
        v_0 = D + 2;
        m_0 = Sum_k(:, k) / N_k(1, k);
        X_k = X(:, Y == k);
        S_0 = diag(diag((X_k - repmat(m_0, [1, size(X_k, 2)])) * (X_k - repmat(m_0, [1, size(X_k, 2)]))')) / N_k(1, k);
        
        n = N_k(1, k);
		kappa_n = kappa_0 + n;
		v_n = v_0 + n;
		m_n = (kappa_0 * m_0 + Sum_k(:, k)) / kappa_n;
		S_ni = S_0 + squeeze(S_k(k, :, :)) + kappa_0 * (m_0 * m_0') - kappa_n * (m_n * m_n');
		m_n = (kappa_0 * m_0 + Sum_k(:, k) - x_i) / (kappa_n - 1);
		S_n = S_0 + squeeze(S_k(k, :, :)) - x_i * x_i' + kappa_0 * (m_0 * m_0') - (kappa_n - 1) * (m_n * m_n');

        p = GIW(kappa_n, v_n, S_ni, S_n, x_i) * (n - 1 + (alpha / K)) / (N + alpha - 1);
        
        k = new_k;
        kappa_0 = 0.01;
        v_0 = D + 2;
        m_0 = Sum_k(:, k) / N_k(1, k);
        X_k = X(:, Y == k);
        S_0 = diag(diag((X_k - repmat(m_0, [1, size(X_k, 2)])) * (X_k - repmat(m_0, [1, size(X_k, 2)]))')) / N_k(1, k);

        n = N_k(1, k) + 1;
		kappa_n = kappa_0 + n;
		v_n = v_0 + n;
		m_n = (kappa_0 * m_0 + Sum_k(:, k) + x_i) / kappa_n;
		S_ni = S_0 + squeeze(S_k(k, :, :)) + x_i * x_i' + kappa_0 * (m_0 * m_0') - kappa_n * (m_n * m_n');
        m_n = (kappa_0 * m_0 + Sum_k(:, k)) / (kappa_n - 1);
        S_n = S_0 + squeeze(S_k(k, :, :)) + kappa_0 * (m_0 * m_0') - (kappa_n - 1) * (m_n * m_n');
		
        new_p = GIW(kappa_n, v_n, S_ni, S_n, x_i) * (n - 1 + (alpha / K)) / (N + alpha - 1);
        k = Y(1, i);
        
		% Evaluate r = min{1,p(yi = new_k | rest) / p(yi = k|rest) * q(k) / q(new_k)}
        r = min([new_p * q(1, k) / (p * q(1, new_k)), 1]);
    end
    % Generate s = Uniform(0; 1) and decide accept or not
    s = rand;
    
    if s < r && new_k ~= k
        Y(1, i) = new_k;
        X_k = zeros(1, D, D);
        X_k(1, :, :) = x_i * x_i';
        S_k(k , :, :) = S_k(k, :, :) - X_k;
        S_k(new_k, :, :) = S_k(new_k, :, :) + X_k;
        Sum_k(:, k) = Sum_k(:, k) - x_i;
        Sum_k(:, new_k) = Sum_k(:, new_k) + x_i;
        N_k(1, k) = N_k(1, k) - 1;
        N_k(1, new_k) = N_k(1, new_k) + 1;
    end
end

% cputime - t
