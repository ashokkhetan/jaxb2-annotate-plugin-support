This project is an attempt to add @JsonValue annotation to value() method of Java enums, generated from .xsd files.

As of commit https://github.com/pavelav/enum-value-annotation/commit/4ed8a42715046278ada13907ed8abcefbdf47004 I get the following errors on `mvn compile`:
```
[ERROR] Error while generating code.Location [ file:/media/Storage/Lab/java/jaxb2-annotate-plugin-support/e/enumValue/schema/Enums.xsd{13,46}].
org.xml.sax.SAXParseException; systemId: file:/media/Storage/Lab/java/jaxb2-annotate-plugin-support/e/enumValue/schema/Enums.xsd; lineNumber: 13; columnNumber: 46; Error parsing annotation.
	at org.jvnet.jaxb2_commons.plugin.annotate.AnnotatePlugin.annotate(AnnotatePlugin.java:382)
	at org.jvnet.jaxb2_commons.plugin.annotate.AnnotatePlugin.annotateEnumOutline(AnnotatePlugin.java:261)
	at org.jvnet.jaxb2_commons.plugin.annotate.AnnotatePlugin.processEnumOutline(AnnotatePlugin.java:174)
	at org.jvnet.jaxb2_commons.plugin.annotate.AnnotatePlugin.run(AnnotatePlugin.java:155)
	at com.sun.tools.xjc.model.Model.generateCode(Model.java:294)
	at org.jvnet.mjiip.v_2_2.XJC22Mojo.generateCode(XJC22Mojo.java:66)
	at org.jvnet.mjiip.v_2_2.XJC22Mojo.doExecute(XJC22Mojo.java:41)
	at org.jvnet.mjiip.v_2_2.XJC22Mojo.doExecute(XJC22Mojo.java:28)
	at org.jvnet.jaxb2.maven2.RawXJC2Mojo.doExecute(RawXJC2Mojo.java:318)
	at org.jvnet.jaxb2.maven2.RawXJC2Mojo.execute(RawXJC2Mojo.java:161)
	at org.apache.maven.plugin.DefaultBuildPluginManager.executeMojo(DefaultBuildPluginManager.java:101)
	at org.apache.maven.lifecycle.internal.MojoExecutor.execute(MojoExecutor.java:209)
	at org.apache.maven.lifecycle.internal.MojoExecutor.execute(MojoExecutor.java:153)
	at org.apache.maven.lifecycle.internal.MojoExecutor.execute(MojoExecutor.java:145)
	at org.apache.maven.lifecycle.internal.LifecycleModuleBuilder.buildProject(LifecycleModuleBuilder.java:84)
	at org.apache.maven.lifecycle.internal.LifecycleModuleBuilder.buildProject(LifecycleModuleBuilder.java:59)
	at org.apache.maven.lifecycle.internal.LifecycleStarter.singleThreadedBuild(LifecycleStarter.java:183)
	at org.apache.maven.lifecycle.internal.LifecycleStarter.execute(LifecycleStarter.java:161)
	at org.apache.maven.DefaultMaven.doExecute(DefaultMaven.java:320)
	at org.apache.maven.DefaultMaven.execute(DefaultMaven.java:156)
	at org.apache.maven.cli.MavenCli.execute(MavenCli.java:537)
	at org.apache.maven.cli.MavenCli.doMain(MavenCli.java:196)
	at org.apache.maven.cli.MavenCli.main(MavenCli.java:141)
	at sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
	at sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:62)
	at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
	at java.lang.reflect.Method.invoke(Method.java:498)
	at org.codehaus.plexus.classworlds.launcher.Launcher.launchEnhanced(Launcher.java:290)
	at org.codehaus.plexus.classworlds.launcher.Launcher.launch(Launcher.java:230)
	at org.codehaus.plexus.classworlds.launcher.Launcher.mainWithExitCode(Launcher.java:409)
	at org.codehaus.plexus.classworlds.launcher.Launcher.main(Launcher.java:352)
Caused by: org.jvnet.annox.parser.exception.AnnotationExpressionParseException: Could not parse the annotation expression [@com.fasterxml.jackson.annotation.JsonValue].
	at org.jvnet.annox.parser.XAnnotationParser.parse(XAnnotationParser.java:246)
	at org.jvnet.annox.parser.XAnnotationParser.parse(XAnnotationParser.java:164)
	at org.jvnet.jaxb2_commons.plugin.annotate.AnnotatePlugin.annotate(AnnotatePlugin.java:375)
	... 30 more
Caused by: org.jvnet.annox.annotation.AnnotationClassNotFoundException: Annotation class [com.fasterxml.jackson.annotation.JsonValue] could not be found.
	... 33 more
Caused by: java.lang.ClassNotFoundException: com.fasterxml.jackson.annotation.JsonValue
	at java.net.URLClassLoader.findClass(URLClassLoader.java:381)
	at java.lang.ClassLoader.loadClass(ClassLoader.java:424)
	at java.lang.ClassLoader.loadClass(ClassLoader.java:357)
	at java.lang.Class.forName0(Native Method)
	at java.lang.Class.forName(Class.java:348)
	at org.apache.commons.lang3.ClassUtils.getClass(ClassUtils.java:828)
	at org.apache.commons.lang3.ClassUtils.getClass(ClassUtils.java:862)
	at org.jvnet.annox.parser.XAnnotationParser.parse(XAnnotationParser.java:228)
	... 32 more
```
