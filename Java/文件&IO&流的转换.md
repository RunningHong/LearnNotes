[TOC]

# 文件&流

## 1 InputStream 转换为byte[]

```java
public byte[] parse(InputStream input) {
    byte[] byt = new byte[input.available()];
    return byt;
}
```

## 2 byte[]转换为InputStream

```java
public InputStream parse(byte[] byt) {
    InputStream input = new ByteArrayInputStream(byt);
    return input;
}
```

## 3 byte[]转换为File

```java
public File parse(byte[] byt) {
    File file = new File('');
    OutputStream output = new FileOutputStream(file);
    BufferedOutputStream bufferedOutput = new BufferedOutputStream(output);
    bufferedOutput.write(byt);
    return file;
}
```

## 4 inputStream转outputStream

```java
public ByteArrayOutputStream parse(InputStream in) throws Exception {
    ByteArrayOutputStream swapStream = new ByteArrayOutputStream();
    int ch;
    while ((ch = in.read()) != -1) {   
        swapStream.write(ch);   
    }
    return swapStream;
}
```

## 5 outputStream转inputStream

```java
public ByteArrayInputStream parse(OutputStream out) throws Exception {
    ByteArrayOutputStream   baos=new ByteArrayOutputStream();
    baos=(ByteArrayOutputStream) out;
    ByteArrayInputStream swapStream = new ByteArrayInputStream(baos.toByteArray());
    return swapStream;
}
```

## 6 inputStream转String

```java
public String parse_String(InputStream in) throws Exception {
    ByteArrayOutputStream swapStream = new ByteArrayOutputStream();
    int ch;
    while ((ch = in.read()) != -1) {   
        swapStream.write(ch);   
    }
    return swapStream.toString();
}
```

## 7 OutputStream转String

```java
public String parse_String(OutputStream out) throws Exception {
    ByteArrayOutputStream   baos=new   ByteArrayOutputStream();
    baos=(ByteArrayOutputStream) out;
    ByteArrayInputStream swapStream = new ByteArrayInputStream(baos.toByteArray());
    return swapStream.toString();
}
```

## 8 String转inputStream

```java
public ByteArrayInputStream parse_inputStream(String in) throws Exception {
    ByteArrayInputStream input=new ByteArrayInputStream(in.getBytes());
    return input;
}
```

## 9 String转outputStream

```java
public ByteArrayOutputStream parse_outputStream(String in) throws Exception {
    // 先转InputStream
    ByteArrayInputStream input=new ByteArrayInputStream(in.getBytes());
    
    // InputStream转String
    ByteArrayOutputStream swapStream = new ByteArrayOutputStream();
    int ch;
    while ((ch = input.read()) != -1) {   
        swapStream.write(ch);   
    }
    return swapStream.toString();
}
```







