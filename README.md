# PKI-Demo
A Demo for PKI system, can generate self-signed root CA, Intermedia Certificate, and sign device CSR

**1. Generate the self signed Root certificate**
```bash
./generate_root.sh
```
 

 if ask you enter pass phrase, please enter the password what you like, eg,1234
 make sure to remember it

**2.Generate the intermiediate certficate**

```bash
 sudo ./generate_intermediate_ca.sh
```
 
  **Root permission is required

**3.sign the leaf certificate(assume csr file is ready,like device.csr is copied in the same folder with sign_device_csr.sh)**

```bash
sudo ./sign_device_csr.sh device.csr
```
  **Root permission is required

