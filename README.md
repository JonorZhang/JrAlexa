# JrAlexa

本项目基于objective-c、Xcode9.4，演示如何集成AVS（Alexa Voice Service）。

## 准备工作
 [*☞详细注册步骤可以戳这里看*](https://developer.amazon.com/docs/alexa-voice-service/register-a-product.html)

1. [注册Amazon开发者账户](https://developer.amazon.com/login.html)
2. [注册并激活你的Alexa产品](https://developer.amazon.com/home.html)

完成以上步骤你就拿到了 `bundleID`、`APIKey` 和 `productID`。

## 创建Xcode项目

- **Bundle Identifier**
    一定要和注册Alexa产品时填写的`bundleID`一样，我的是`com.jonor.JrAlexa`。
    
- **info.plist**
    - 新增 APIKey
    `APIKey : eyJhbGciOiJSU0EtU0hBMjU2IiwidmVyIjoiMSJ9...(很长一串)`
    
    - 新增 URL Types
    `URL Types` : [{
        `Identifier` : `com.jonor.JrAlexa`
        `URL Schemes` : [`amzn-com.jonor.JrAlexa`]
    }]

- **导入登陆框架** 
    - 导入`LoginWithAmazon.framework`
    - 添加依赖框架`SafariServices.framework`、`Security.framework`。

## 示例代码
   请看demo [☞JrAlexa](https://github.com/JonorZhang/JrAlexa)

## 官方文档
更多详细内容请移步：[☞Get Started With Alexa Voice Service](https://developer.amazon.com/docs/alexa-voice-service/get-started-with-alexa-voice-service.html)


