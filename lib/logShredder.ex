defmodule LogShredder do
  def last_chunk(filename, chunk_size_in_kb) do
    case filename |> File.exists? do
      false ->
        throw "File #{filename} does not exist}"
      true -> true
    end
    file_io_device =
    case filename |> :file.open([:read, {:encoding, :latin1}]) do
      {:ok, iodevice} ->
        iodevice
      {:error, reason} ->
        throw "Unable to open a file for a reason: #{{reason}}"
    end
    case file_io_device |> :file.position({:eof, -chunk_size_in_kb * 1024}) do
      {:ok, new_position} -> IO.puts "File pointer now has new position #{inspect new_position}"
      {:error, reason} -> throw "It was unable to reset a file pointer to a new position does to: #{reason}"
    end
    ext = filename |> :filename.extension
    base_name = filename |> :filename.basename
    filename_wo_ext = base_name |> binary_part(0, String.length(base_name) - String.length(ext))
    new_filename = filename |> Path.dirname |> add_head([filename_wo_ext <> "___" <> (:random.uniform(10000) |> Integer.to_string) <> ext]) |> Path.join()
    new_file_io_device =
    case new_filename |> File.open([:write]) do
      {:ok, new_io_device} -> new_io_device
      {:error, reason} -> throw "Unable to open new file #{new_filename}} for write due to: #{reason}"
    end
    file_io_device |> IO.binstream(4096) |> Enum.each(&(new_file_io_device |> IO.write(&1)))  # Stream by 4096 bytes
    new_file_io_device |> File.close
    IO.puts "Outputted remaining #{chunk_size_in_kb} into #{new_filename}"
  end

  defp add_head(item, list), do: [item|list]
end
