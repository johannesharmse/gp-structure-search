function plot_decomp(X, y, complete_covfunc, complete_hypers, decomp_list, decomp_hypers, noise, figname, latex_names)

% TODO: Assert that the sum of all kernels is the same as the complete kernel.

x_left = min(X) - (max(X) - min(X))*0.1;
x_right = max(X) + (max(X) - min(X))*0.1;
xrange = linspace(x_left, x_right, 1000)';

% TODO: check if noise formula is correct.
complete_sigma = feval(complete_covfunc{:}, complete_hypers, X, X) + eye(length(y)).*exp(noise);
complete_sigmastar = feval(complete_covfunc{:}, complete_hypers, X, xrange);
complete_sigmastarstart = feval(complete_covfunc{:}, complete_hypers, xrange, xrange);

% First, plot the original, combined kernel
complete_mean = complete_sigmastar' / complete_sigma * y;
complete_var = diag(complete_sigmastarstart - complete_sigmastar' / complete_sigma * complete_sigmastar);
    
figure(1); clf; hold on;
plot( X, y, '.' ); hold on; 
mean_var_plot(xrange, complete_mean, 2.*sqrt(complete_var));
title(latex_names{end});
filename = sprintf('%s_all.fig', figname);
saveas( gcf, filename );
filename = sprintf('%s_all.pdf', figname);
save2pdf( filename, gcf, 400, true )

for i = 1:numel(decomp_list)
    cur_cov = decomp_list{i};
    cur_hyp = decomp_hypers{i};
    
    % Compute mean and variance for this kernel.
    decomp_sigma = feval(cur_cov{:}, cur_hyp, X, X);
    decomp_sigma_star = feval(cur_cov{:}, cur_hyp, X, xrange);
    decomp_sigma_starstar = feval(cur_cov{:}, cur_hyp, xrange, xrange);
    decomp_mean = decomp_sigma_star' / complete_sigma * y;
    decomp_var = diag(decomp_sigma_starstar - decomp_sigma_star' / complete_sigma * decomp_sigma_star);
    
    % Compute the remaining signal after removing the mean prediction from all
    % other parts of the kernel.
    removed_mean = y - (complete_sigma - decomp_sigma)' / complete_sigma * y;
    
    figure(i + 1); clf; hold on;
    plot( X, removed_mean, '.' ); hold on; 
    mean_var_plot(xrange, decomp_mean, 2.*sqrt(decomp_var));
    title(latex_names{i});
    filename = sprintf('%s_%d.fig', figname, i);
    saveas( gcf, filename );
    filename = sprintf('%s_%d.pdf', figname, i);
    save2pdf( filename, gcf, 400, true )

    fprintf('.');
end
end


function mean_var_plot( xrange, forecast_mu, forecast_scale )
    % Figure settings.
    lw = 1.2;
    opacity = 0.2;
 
    plot(xrange, forecast_mu, 'Color', colorbrew(2), 'LineWidth', lw); hold on;
    
    % Plot confidence bears.
    jbfill( xrange', ...
            forecast_mu' + forecast_scale', ...
            forecast_mu' - forecast_scale', ...
            colorbrew(2), 'none', 1, opacity); hold on;
    
    % Make plot prettier.
    set(gcf, 'color', 'white');
    set(gca, 'TickDir', 'out');
end
