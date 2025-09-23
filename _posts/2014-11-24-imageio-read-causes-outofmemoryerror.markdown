---
layout: post
title: "ImageIO.read() causes OutOfMemoryError"
permalink: /tech/imageio-read-causes-outofmemoryerror/
last_modified_at: 2024-01-27
---

## The problem

Few days ago, a reader contacted me with a problem he had in a piece of code. The code was creating thumbnails from images and was throwing an `OutOfMemoryError` after few dozens of images. Here is the simplified code, line 26 `ImageIO.read(file)`, throws `OutOfMemoryError`:

```java
package com.opcodesolutions.demo;

import java.awt.Image;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import javax.imageio.ImageIO;

public class Thumbnails {

    public static void main(String[] args) throws IOException {

        List<Image> thumbnails = new ArrayList<>();

        for (File file : new File("/path/to/images/").listFiles()) {

            if (!file.getName().endsWith(".jpg")) {
                // File is NOT a JPEG
                continue;
            }

            BufferedImage fullSizeImage = ImageIO.read(file); // OutOfMemoryError
            if (fullSizeImage == null) {
                // Could not parse JPEG, just ignore
                continue;
            }

            // Create thumbnail
            Image thumbnail = fullSizeImage
                .getScaledInstance(150, 150, Image.SCALE_DEFAULT);
            thumbnails.add(thumbnail);
        }

        // Do more stuff with thumbnails

    }

}
```

And here is the stacktrace with the `OutOfMemoryError`:

```java
Exception in thread "main" java.lang.OutOfMemoryError: Java heap space
    at java.awt.image.DataBufferByte.<init>(DataBufferByte.java:92)
    at java.awt.image.ComponentSampleModel.createDataBuffer(ComponentSampleModel.java:415)
    at java.awt.image.Raster.createWritableRaster(Raster.java:941)
    at javax.imageio.ImageTypeSpecifier.createBufferedImage(ImageTypeSpecifier.java:1073)
    at javax.imageio.ImageReader.getDestination(ImageReader.java:2896)
    at com.sun.imageio.plugins.jpeg.JPEGImageReader.readInternal(JPEGImageReader.java:1066)
    at com.sun.imageio.plugins.jpeg.JPEGImageReader.read(JPEGImageReader.java:1034)
    at javax.imageio.ImageIO.read(ImageIO.java:1448)
    at javax.imageio.ImageIO.read(ImageIO.java:1308)
    at com.opcodesolutions.demo.Thumbnails.main(Thumbnails.java:26)
```

## The cause of the OutOfMemoryError

The cause of that problem is not obvious. The stacktrace (and the title of this article) is somewhat misleading. Here is what happens: The call to `fullSizeImage.getScaledInstance()` (lines 33-34) produces a smaller image thumbnail, but that thumbnail object keeps a reference to the `fullSizeImage`. Since JPEG files are highly compressed, reading and parsing them takes a significant amount of memory and that memory can never be freed.

## The solution: Do not use Image.getScaledInstance()

The solution was to replace the call to `fullSizeImage.getScaledInstance()` with the lines 34-38 highlighted below. That solution allowed the code to read thousands of images, because the `fullSizeImage` was no longer kept in memory.

```java
package com.opcodesolutions.demo;

import java.awt.Graphics2D;
import java.awt.Image;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import javax.imageio.ImageIO;

public class Thumbnails {

    public static void main(String[] args) throws IOException {

        List<Image> thumbnails = new ArrayList<>();

        for (File file : new File("/path/to/images/").listFiles()) {

            if (!file.getName().endsWith(".jpg")) {
                // File is NOT a JPEG
                continue;
            }

            BufferedImage fullSizeImage = ImageIO.read(file);
            if (fullSizeImage == null) {
                // Could not parse JPEG, just ignore
                continue;
            }

            // Create thumbnail
            BufferedImage thumbnail = new BufferedImage(150, 150,
                BufferedImage.TYPE_INT_ARGB);
            Graphics2D g = thumbnail.createGraphics();
            g.drawImage(fullSizeImage, 0, 0, 150, 150, null);
            g.dispose();
            thumbnails.add(thumbnail);
        }

        // Do more stuff with thumbnails

    }

}
```

## References

From Oracle's website: [How do I create a resized copy of an image?](https://www.oracle.com/java/technologies/java2d.html#Q_How_do_I_create_a_resized_copy)

For this particular problem, I did not need to produce a heap dump, because the code was small enough. With a few tests and a few searches on Google, I could figure-out what was happening. However, if you have no idea where the `OutOfMemoryError` comes from, you may want to read this article: [How to fix java.lang.OutOfMemoryError: Java heap space](/tech/solve-java-lang-outofmemoryerror-java-heap-space/).

*Author: [Jonathan Demers](https://jonathandemers.ca/ "Jonathan Demers"). See on [LinkedIn](https://www.linkedin.com/in/jonathan-demers-ing/ "Jonathan Demers on LinkedIn").*