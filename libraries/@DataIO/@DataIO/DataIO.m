%{
    This class creates a 'nan' variable of given dimensions.
    You can use this function to mainly store/retrieve data in a std.
    fashion.
%}

classdef DataIO < handle
    properties (Access = private)
        data
        vec_len
        num_readings
        index
    end
    
    methods        
        %% Constructor
        function obj = DataIO(vec_len, num_readings)           
            obj.vec_len = vec_len;            
            obj.num_readings = num_readings;

            obj.clear();
        end
       
        %% List of other (public) functions:
        store(obj, data);
        data = retrieve(varargin); % ArgIn: (obj, transpose_or_not, retrieve_particular_row/col)
        count = getCount(obj);
        sort(varargin); % ArgIn: (obj, 0:sortcols or 1:sortrows, sort_by_row/col_no)
        overwrite(obj, data);
        clear(obj);
    end
end