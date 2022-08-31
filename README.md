# 1. Overview
gdbusx provides simple GDBus APIs.

Please edit your  *.xml, run gdbus-codegen to generate C code. Then merge into your project and communicate between applications over GDBus.

# 2. Depend on

- [utilx9](https://github.com/lankahsu520/utilx9)

# 3. Current Status



# 4. Build
   ```
$ make
   ```

# 5. Example or Usage
- gdbusx_123 - gdbusx example.


# 6. License
gdbusx is under the New BSD License (BSD-3-Clause).


# 7. Documentation
Run an example and read it.

## 7.1. TestCase A

```c
<method name="SetNameAge">
  <arg name="name" type="s" direction="in"/>
  <arg name="age" type="i" direction="in"/>
  <arg name="response" type="s" direction="out"/>
</method>

GDBUSX_METHOD_COMPLETE(GDBUSX_IFAC_FUNC_AGENT, _set_name_age)(object, invocation, retStr);

```

```c
<signal name="Bonjour">
  <arg name="greeting" type="s"/>
</signal>

gbusx_signal_int(gbusx_req, "bonjour", gbusx_signal_Agent_Bonjour_cb);
```

### 7.1.1. Method

```mermaid
sequenceDiagram
	participant client as gdbusx_123
	participant server as gdbusx_123 -s

	client->>server: gbusx_method_Agent_SetNameAge(arg_name: Mary, arg_age: 18)
	server->>client: Hello world !!! (Mary-18)
	client->>server: gbusx_method_Boss_SetNameAge(arg_name: Lanka, arg_age: 19)
	server->>client: Yes sir !!! (Lanka-19)

```
### 7.1.2. Signal

```mermaid
sequenceDiagram
	participant client as gdbusx_123
	participant server as gdbusx_123 -s

	server->>client: gbusx_signal_Agent_Bonjour_cb

```