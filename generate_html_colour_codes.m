function cols = generate_html_colour_codes(list_length)
% creates a list of HTML colour codes list_length long.
% generate random numbers in the range 40 - 238. The full range os 0-255
% but the fully saturated colours may be used for specific functions, so
% this function restricts the area of the colour map used.
% Example: cols = generate_html_colour_codes(list_length)

red_nums = randi([40 238],[list_length 1]);
blue_nums = randi([40 238],[list_length 1]);
green_nums = randi([40 238],[list_length 1]);
% use rounding to enforce a particular separation of the colours.
red_nums = round(red_nums .* 30) ./30;
blue_nums = round(blue_nums .* 30) ./30;
green_nums = round(green_nums .* 30) ./30;

% convert the numbers to hex so they conform to the HTML spec.
red_nums_html = dec2hex(red_nums);
blue_nums_html = dec2hex(blue_nums);
green_nums_html = dec2hex(green_nums);
cols = [red_nums_html, green_nums_html, blue_nums_html];
cols = unique(cols,'rows');
