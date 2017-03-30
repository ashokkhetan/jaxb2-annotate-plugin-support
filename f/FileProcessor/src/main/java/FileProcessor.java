package main.java;

import java.io.File;
import java.io.IOException;
import java.nio.file.FileSystems;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.nio.file.StandardWatchEventKinds;
import java.nio.file.WatchEvent;
import java.nio.file.WatchKey;
import java.nio.file.WatchService;

public class FileProcessor implements Runnable
{
    private final String working;
    private Path toWatch;
    private final OMSMessageDao dao;

    public FileProcessor(String working, OMSMessageDao dao)
    {
        this.dao = dao;
        this.working = working;
        toWatch = Paths.get(working);
        if (toWatch == null)
        {
            throw new UnsupportedOperationException("Directory not found");
        }
    }

    @Override
    public void run()
    {
        try
        {
            watchMyFiles();
        }
        catch (Exception e)
        {
            e.printStackTrace();
        }
    }

    public void watchMyFiles() throws IOException, InterruptedException
    {
        WatchService watchService = FileSystems.getDefault().newWatchService();
        toWatch.register(watchService, StandardWatchEventKinds.ENTRY_CREATE);

        boolean valid = true;
        do
        {
            WatchKey watchKey = watchService.take();

            for (WatchEvent event : watchKey.pollEvents())
            {
                WatchEvent.Kind kind = event.kind();
                if (StandardWatchEventKinds.ENTRY_CREATE.equals(event.kind()))
                {
                    String fileName = event.context().toString();
                    System.out.println("File Created:" + fileName);

                    handleCreate((Path)event.context());
                }
            }
            valid = watchKey.reset();

        } while (valid);
    }

    private boolean handleCreate(Path context) throws IOException, InterruptedException
    {
        Path filename = context.getFileName();
        try
        {
            Path movefrom = null;
            Path target = null;
            if (working.equalsIgnoreCase(FileImport.WORKING))
            {
                File file = new File(FileImport.WORKING + File.separator + filename);
                dao.processFile(file);

            }
            else if (working.equalsIgnoreCase(FileImport.PATH))
            {
                try
                {
                    movefrom = FileSystems.getDefault().getPath(FileImport.PATH + File.separator + filename);
                    target = FileSystems.getDefault().getPath(FileImport.WORKING + File.separator + filename);
                    Files.move(movefrom, target, StandardCopyOption.REPLACE_EXISTING);
                }
                catch (Exception e)
                {
                    handleCreate(context);
                }
            }
            return true;
        }
        catch (Exception e)
        {
            throw e;
        }
    }

    private void handleDelete(Path context)
    {
    }

    private void handleModify(Path context)
    {
    }
}
