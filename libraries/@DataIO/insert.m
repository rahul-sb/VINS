function insert(obj, transposed, new_data, idx)
% ArgIn: (obj, 0/1 : insert vectors or transpose of vectors, new_data, indices)
    
    data = obj.data;
    
    if ~transposed
        if any(idx > obj.index-1)
            warning("Inserting only vectors that whos index <= the current index")
            new_idx = idx(idx < obj.index);
            new_data = new_data(:,1:length(new_idx));
        else
            new_idx = idx;
            if length(new_idx) > size(new_data,2)
                warning("No. of indices > No. of data provided. Not inserting any data");
            elseif length(new_idx) < size(new_data,2)        
                warning("No. of indices < No. of data provided doesn't match. Inserting in order received");
                new_data = new_data(:,1:length(new_idx));
            else
                new_data = new_data(:,1:length(new_idx));
            end
        end
        
        data(:,new_idx) = new_data;
        
    else        
        if any(idx > obj.vec_len)
            warning("Inserting only rows that whos index <= the vector length")
            new_idx = idx(idx <= obj.vec_len);
            new_data = new_data(1:length(new_idx),:);
        else
            new_idx = idx;
        end
        
        if size(new_data,2) ~= obj.index-1
            warning("Far too less columns. Give columsn that equal the num of indices");
        else
            data(new_idx, 1:obj.index-1) = new_data;
        end
    end    
    obj.data = data;
end