function data = retrieve(varargin)
% ArgIn: (obj, transpose_or_not, retrieve_particular_row/col)
    data = varargin{1}.data(:, 1:varargin{1}.index-1);
    
    if nargin == 2
        if varargin{2}
            data = data';
        end
    elseif nargin == 3
        if varargin{2}
            data = data';
        end
        
        idx = varargin{3} > varargin{1}.index-1;
        
        if idx(1)
            data = [];
        else        
            try
                data = data(:,varargin{3});
            catch
                warning("Unable to find Index in data");
            end
        end
        
        if varargin{2}
            data = data';
        end
    elseif nargin > 3
        warning("Too many i/p arguments, returning what is available");
    end
end