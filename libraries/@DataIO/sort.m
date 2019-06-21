function sort(varargin)
% ArgIn: (obj, 0:sortcols or 1:sortrows, sort_by_row/col_no)
if nargin == 1
    temp_data = varargin{1}.data';
elseif nargin > 1
    if varargin{2} == 1
        temp_data = varargin{1}.data;
    elseif varargin{2} == 0
        temp_data = varargin{1}.data';
    else
        warning("Invalid argument. Sorting columns");
        temp_data = varargin{1}.data';
    end
end

if nargin == 3
    try
        temp_data = sortrows(temp_data, varargin{3});
    catch
        warning("Index exceeds dimension. Not Sorting!");
    end
else
    temp_data = sortrows(temp_data);
end 

if nargin == 1
    varargin{1}.data = temp_data';
elseif nargin > 1
    if varargin{2} == 1
        varargin{1}.data = temp_data;
    else
        varargin{1}.data = temp_data';
    end
end

end