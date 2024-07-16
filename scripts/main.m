clear; close all; clc; 

%% --- USER INPUTS ---
DATA_FILE = '../data/Electric_Production.csv'; % https://www.kaggle.com/datasets/shenba/time-series-datasets
% DATA_FILE = '../data/Month_Value_1.csv'; % https://www.kaggle.com/datasets/podsyp/time-series-starter-dataset
% DATA_FILE = '../data/POP.csv';  % https://www.kaggle.com/datasets/census/population-time-series-data
CONFIG_FILE = 'Config.csv';

%% --- MAIN ---
[show_mean, show_fit, x_label, y_label] = get_config(CONFIG_FILE);
make_plot(DATA_FILE, show_mean, show_fit, x_label, y_label)

%% --- SUPPORT FUNCTIONS ---
function [show_mean, show_fit, x_label, y_label] = get_config(filename)
% GET_CONFIG  Parse specified configuration file.
%   [SHOW_MEAN, SHOW_FIT, X_LABEL, Y_LABEL] = GET_CONFIG(FILENAME) loads
%   a specified CSV file that has three columns: Key, Value, Comments. The 
%   keys can be {'SHOW_MEAN', 'SHOW_FIT', 'X_LABEL', 'Y_LABEL'} to show the
%   mean value line, show a linear fit line, display given x-label on plot,
%   or display given y-label on plot, respectively. 

    % Defaults 
    show_mean = true; 
    show_fit = true;
    x_label = 'X';  
    y_label = 'Y'; 

    % Load table from file 
    opts = detectImportOptions(filename);
    opts = setvartype(opts, 'char');
    data = readtable(filename,opts);  

    % Parse inputs 
    for i = 1:length(data.Key)
        key = string(data.Key{i});
        val = data.Value{i}; 
        if all(key == 'show_mean')
            show_mean = logical(val);
        elseif all(key == 'show_fit')
            show_fit = logical(val); 
        elseif all(key == 'xlabel')
            x_label = val;
        elseif all(key == 'ylabel')
            y_label = val; 
        end
    end
end

function y_pred = fit_linear(dates, y)
% FIT_LINEAR  Fit a straight line through the data.
%   y_pred = FIT_LINEAR(DATES, Y) fits a 1st order polynomial where the 
%   inputs are dates and the outputs are floats. Returns predicted values 
%   of y evaluated at dates.

    durations = dates - min(dates); 
    x = seconds(durations);  % convert to float
    p = polyfit(x, y, 1); 
    y_pred = polyval(p,x); 
end

function make_plot(filename, show_mean, show_fit, x_label, y_label)
% MAKE_PLOT  Plot specified timeseries.
%   C = MAKE_PLOT(FILENAME, SHOW_MEAN, SHOW_FIT, X_LABEL, Y_LABEL) create 
%   line plot of timeseries described in file, where FILENAME is the name
%   of a CSV file containing the timeseries with 1st and 2nd columns
%   representing the dates and response, respectively. Use SHOW_MEAN, 
%   SHOW_FIT, X_LABEL, Y_LABEL to show the mean value line, show a linear 
%   fit line, display given x-label or y-label on plot, respectively. 
    opts = detectImportOptions(filename);
    % opts = setvaropts(opts,1,'inputFormat','dd/MM/uuuu');
    data = readtable(filename,opts); 
    data = rmmissing(data);
    data = sortrows(data, 1); 
    
    x = data.(1); 
    y = data.(2); 
    
    fig = figure('visible','off'); 
    hold on 
    grid on
    xlabel(x_label)
    ylabel(y_label)
    title(strcat(x_label, ' vs. ', y_label))
    plot(x, y, 'k.-')
    items = {'timeseries'};
    
    if show_mean == 1
        yavg = mean(y); 
        plot([x(1) x(end)], [yavg, yavg], 'r--', LineWidth=3)
        items{length(items)+1} = 'mean value line';
    end 

    if show_fit
        y_pred = fit_linear(x, y);
        plot(x, y_pred, 'b--', LineWidth=3);
        items{length(items)+1} = 'linear fit line';
    end

    legend(items,"Location","best") 

    tokens = strsplit(filename, '.');
    root = tokens{1};
    saveas(fig,strcat(root, '.', 'png'))
end




