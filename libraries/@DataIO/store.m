function store(obj, data)
    
    if ~isempty(data)
        [vec_len, num_readings] = size(data);

        if vec_len~=obj.vec_len
            warning("DataIO vector length mismatch. Data not stored!");
        elseif num_readings > 0
            est_readings = obj.index-1 + num_readings;

            % Increase the size of the matrix to store more data.
            if est_readings > obj.num_readings
                obj.num_readings = ceil(est_readings/obj.num_readings)*obj.num_readings;
                temp_data = obj.retrieve();
                temp_index = obj.index;

                obj.clear();

                obj.index = temp_index;
                obj.data(:,1:obj.index-1) = temp_data;
            end

            obj.data(:, obj.index:est_readings) = data;
            obj.index = obj.index + num_readings;
        end
    end

end
