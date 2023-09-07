# frozen_string_literal: true

FactoryBot.define do
  factory :pages_domain, class: 'PagesDomain' do
    sequence(:domain) { |n| "my#{n}.domain.com" }
    verified_at { Time.now }
    enabled_until { 1.week.from_now }

    certificate do
      File.read(Rails.root.join('spec/fixtures/', 'ssl_certificate.pem'))
    end

    key do
      File.read(Rails.root.join('spec/fixtures/', 'ssl_key.pem'))
    end

    trait :disabled do
      verified_at { nil }
      enabled_until { nil }
    end

    trait :scheduled_for_removal do
      remove_at { 1.day.from_now }
    end

    trait :should_be_removed do
      remove_at { 1.day.ago }
    end

    trait :unverified do
      verified_at { nil }
    end

    trait :reverify do
      enabled_until { 1.hour.from_now }
    end

    trait :expired do
      enabled_until { 1.hour.ago }
    end

    trait :without_certificate do
      certificate { nil }
    end

    trait :without_key do
      key { nil }
    end

    trait :with_missing_chain do
      # This certificate is signed with different key
      # And misses the CA to build trust chain
      certificate do
        '-----BEGIN CERTIFICATE-----
MIIDGTCCAgGgAwIBAgIBAjANBgkqhkiG9w0BAQUFADASMRAwDgYDVQQDEwdUZXN0
IENBMB4XDTE2MDIxMjE0MjMwMFoXDTE3MDIxMTE0MjMwMFowHTEbMBkGA1UEAxMS
dGVzdC1jZXJ0aWZpY2F0ZS0yMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKC
AQEAw8RWetIUT0YymSuKvBpClzDv/jQdX0Ch+2iF7f4Lm3lcmoUuXgyhl/WRe5K9
ONuMHPQlZbeavEbvWb0BsU7geInhsjd/zAu3EP17jfSIXToUdSD20wcSG/yclLdZ
qhb6NCtHTJKFUI8BktoS7kafkdvmeem/UJFzlvcA6VMyGDkS8ZN39a45R1jGmPEl
Yk0g1jW7lSKcBLjU1O/Csv59LyWXqBP6jR1vB8ijlUf1IyK8gOk7NHF13GHl7Z3A
/8zwuEt/pB3yK92o71P+FnSEcJ23zcAalz6H9ajVTzRr/AXttineBNVYnEuPXW+V
Rsboe+bBO/e4pVKXnQ1F3aMT7QIDAQABo28wbTAMBgNVHRMBAf8EAjAAMB0GA1Ud
DgQWBBSFwo3rhc26lD8ZVaBVcUY1NyCOLDALBgNVHQ8EBAMCBeAwEQYJYIZIAYb4
QgEBBAQDAgZAMB4GCWCGSAGG+EIBDQQRFg94Y2EgY2VydGlmaWNhdGUwDQYJKoZI
hvcNAQEFBQADggEBABppUhunuT7qArM9gZ2gLgcOK8qyZWU8AJulvloaCZDvqGVs
Qom0iEMBrrt5+8bBevNiB49Tz7ok8NFgLzrlEnOw6y6QGjiI/g8sRKEiXl+ZNX8h
s8VN6arqT348OU8h2BixaXDmBF/IqZVApGhR8+B4fkCt0VQmdzVuHGbOQXMWJCpl
WlU8raZoPIqf6H/8JA97pM/nk/3CqCoHsouSQv+jGY4pSL22RqsO0ylIM0LDBbmF
m4AEaojTljX1tMJAF9Rbiw/omam5bDPq2JWtosrz/zB69y5FaQjc6FnCk0M4oN/+
VM+d42lQAgoq318A84Xu5vRh1KCAJuztkhNbM+w=
-----END CERTIFICATE-----'
      end
    end

    trait :with_trusted_chain do
      # This contains
      # [Intermediate #2 (SHA-2)] 'Comodo RSA Domain Validation Secure Server CA'
      # [Intermediate #1 (SHA-2)] 'COMODO RSA Certification Authority'
      certificate do
        '-----BEGIN CERTIFICATE-----
MIIGCDCCA/CgAwIBAgIQKy5u6tl1NmwUim7bo3yMBzANBgkqhkiG9w0BAQwFADCB
hTELMAkGA1UEBhMCR0IxGzAZBgNVBAgTEkdyZWF0ZXIgTWFuY2hlc3RlcjEQMA4G
A1UEBxMHU2FsZm9yZDEaMBgGA1UEChMRQ09NT0RPIENBIExpbWl0ZWQxKzApBgNV
BAMTIkNPTU9ETyBSU0EgQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkwHhcNMTQwMjEy
MDAwMDAwWhcNMjkwMjExMjM1OTU5WjCBkDELMAkGA1UEBhMCR0IxGzAZBgNVBAgT
EkdyZWF0ZXIgTWFuY2hlc3RlcjEQMA4GA1UEBxMHU2FsZm9yZDEaMBgGA1UEChMR
Q09NT0RPIENBIExpbWl0ZWQxNjA0BgNVBAMTLUNPTU9ETyBSU0EgRG9tYWluIFZh
bGlkYXRpb24gU2VjdXJlIFNlcnZlciBDQTCCASIwDQYJKoZIhvcNAQEBBQADggEP
ADCCAQoCggEBAI7CAhnhoFmk6zg1jSz9AdDTScBkxwtiBUUWOqigwAwCfx3M28Sh
bXcDow+G+eMGnD4LgYqbSRutA776S9uMIO3Vzl5ljj4Nr0zCsLdFXlIvNN5IJGS0
Qa4Al/e+Z96e0HqnU4A7fK31llVvl0cKfIWLIpeNs4TgllfQcBhglo/uLQeTnaG6
ytHNe+nEKpooIZFNb5JPJaXyejXdJtxGpdCsWTWM/06RQ1A/WZMebFEh7lgUq/51
UHg+TLAchhP6a5i84DuUHoVS3AOTJBhuyydRReZw3iVDpA3hSqXttn7IzW3uLh0n
c13cRTCAquOyQQuvvUSH2rnlG51/ruWFgqUCAwEAAaOCAWUwggFhMB8GA1UdIwQY
MBaAFLuvfgI9+qbxPISOre44mOzZMjLUMB0GA1UdDgQWBBSQr2o6lFoL2JDqElZz
30O0Oija5zAOBgNVHQ8BAf8EBAMCAYYwEgYDVR0TAQH/BAgwBgEB/wIBADAdBgNV
HSUEFjAUBggrBgEFBQcDAQYIKwYBBQUHAwIwGwYDVR0gBBQwEjAGBgRVHSAAMAgG
BmeBDAECATBMBgNVHR8ERTBDMEGgP6A9hjtodHRwOi8vY3JsLmNvbW9kb2NhLmNv
bS9DT01PRE9SU0FDZXJ0aWZpY2F0aW9uQXV0aG9yaXR5LmNybDBxBggrBgEFBQcB
AQRlMGMwOwYIKwYBBQUHMAKGL2h0dHA6Ly9jcnQuY29tb2RvY2EuY29tL0NPTU9E
T1JTQUFkZFRydXN0Q0EuY3J0MCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5jb21v
ZG9jYS5jb20wDQYJKoZIhvcNAQEMBQADggIBAE4rdk+SHGI2ibp3wScF9BzWRJ2p
mj6q1WZmAT7qSeaiNbz69t2Vjpk1mA42GHWx3d1Qcnyu3HeIzg/3kCDKo2cuH1Z/
e+FE6kKVxF0NAVBGFfKBiVlsit2M8RKhjTpCipj4SzR7JzsItG8kO3KdY3RYPBps
P0/HEZrIqPW1N+8QRcZs2eBelSaz662jue5/DJpmNXMyYE7l3YphLG5SEXdoltMY
dVEVABt0iN3hxzgEQyjpFv3ZBdRdRydg1vs4O2xyopT4Qhrf7W8GjEXCBgCq5Ojc
2bXhc3js9iPc0d1sjhqPpepUfJa3w/5Vjo1JXvxku88+vZbrac2/4EjxYoIQ5QxG
V/Iz2tDIY+3GH5QFlkoakdH368+PUq4NCNk+qKBR6cGHdNXJ93SrLlP7u3r7l+L4
HyaPs9Kg4DdbKDsx5Q5XLVq4rXmsXiBmGqW5prU5wfWYQ//u+aen/e7KJD2AFsQX
j4rBYKEMrltDR5FL1ZoXX/nUh8HCjLfn4g8wGTeGrODcQgPmlKidrv0PJFGUzpII
0fxQ8ANAe4hZ7Q7drNJ3gjTcBpUC2JD5Leo31Rpg0Gcg19hCC0Wvgmje3WYkN5Ap
lBlGGSW4gNfL1IYoakRwJiNiqZ+Gb7+6kHDSVneFeO/qJakXzlByjAA6quPbYzSf
+AZxAeKCINT+b72x
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
MIIF2DCCA8CgAwIBAgIQTKr5yttjb+Af907YWwOGnTANBgkqhkiG9w0BAQwFADCB
hTELMAkGA1UEBhMCR0IxGzAZBgNVBAgTEkdyZWF0ZXIgTWFuY2hlc3RlcjEQMA4G
A1UEBxMHU2FsZm9yZDEaMBgGA1UEChMRQ09NT0RPIENBIExpbWl0ZWQxKzApBgNV
BAMTIkNPTU9ETyBSU0EgQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkwHhcNMTAwMTE5
MDAwMDAwWhcNMzgwMTE4MjM1OTU5WjCBhTELMAkGA1UEBhMCR0IxGzAZBgNVBAgT
EkdyZWF0ZXIgTWFuY2hlc3RlcjEQMA4GA1UEBxMHU2FsZm9yZDEaMBgGA1UEChMR
Q09NT0RPIENBIExpbWl0ZWQxKzApBgNVBAMTIkNPTU9ETyBSU0EgQ2VydGlmaWNh
dGlvbiBBdXRob3JpdHkwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQCR
6FSS0gpWsawNJN3Fz0RndJkrN6N9I3AAcbxT38T6KhKPS38QVr2fcHK3YX/JSw8X
pz3jsARh7v8Rl8f0hj4K+j5c+ZPmNHrZFGvnnLOFoIJ6dq9xkNfs/Q36nGz637CC
9BR++b7Epi9Pf5l/tfxnQ3K9DADWietrLNPtj5gcFKt+5eNu/Nio5JIk2kNrYrhV
/erBvGy2i/MOjZrkm2xpmfh4SDBF1a3hDTxFYPwyllEnvGfDyi62a+pGx8cgoLEf
Zd5ICLqkTqnyg0Y3hOvozIFIQ2dOciqbXL1MGyiKXCJ7tKuY2e7gUYPDCUZObT6Z
+pUX2nwzV0E8jVHtC7ZcryxjGt9XyD+86V3Em69FmeKjWiS0uqlWPc9vqv9JWL7w
qP/0uK3pN/u6uPQLOvnoQ0IeidiEyxPx2bvhiWC4jChWrBQdnArncevPDt09qZah
SL0896+1DSJMwBGB7FY79tOi4lu3sgQiUpWAk2nojkxl8ZEDLXB0AuqLZxUpaVIC
u9ffUGpVRr+goyhhf3DQw6KqLCGqR84onAZFdr+CGCe01a60y1Dma/RMhnEw6abf
Fobg2P9A3fvQQoh/ozM6LlweQRGBY84YcWsr7KaKtzFcOmpH4MN5WdYgGq/yapiq
crxXStJLnbsQ/LBMQeXtHT1eKJ2czL+zUdqnR+WEUwIDAQABo0IwQDAdBgNVHQ4E
FgQUu69+Aj36pvE8hI6t7jiY7NkyMtQwDgYDVR0PAQH/BAQDAgEGMA8GA1UdEwEB
/wQFMAMBAf8wDQYJKoZIhvcNAQEMBQADggIBAArx1UaEt65Ru2yyTUEUAJNMnMvl
wFTPoCWOAvn9sKIN9SCYPBMtrFaisNZ+EZLpLrqeLppysb0ZRGxhNaKatBYSaVqM
4dc+pBroLwP0rmEdEBsqpIt6xf4FpuHA1sj+nq6PK7o9mfjYcwlYRm6mnPTXJ9OV
2jeDchzTc+CiR5kDOF3VSXkAKRzH7JsgHAckaVd4sjn8OoSgtZx8jb8uk2Intzna
FxiuvTwJaP+EmzzV1gsD41eeFPfR60/IvYcjt7ZJQ3mFXLrrkguhxuhoqEwWsRqZ
CuhTLJK7oQkYdQxlqHvLI7cawiiFwxv/0Cti76R7CZGYZ4wUAc1oBmpjIXUDgIiK
boHGhfKppC3n9KUkEEeDys30jXlYsQab5xoq2Z0B15R97QNKyvDb6KkBPvVWmcke
jkk9u+UJueBPSZI9FoJAzMxZxuY67RIuaTxslbH9qh17f4a+Hg4yRvv7E491f0yL
S0Zj/gA0QHDBw7mh3aZw4gSzQbzpgJHqZJx64SIDqZxubw5lT2yHh17zbqD5daWb
QOhTsiedSrnAdyGN/4fy3ryM7xfft0kL0fJuMAsaDk527RH89elWsn2/x20Kk4yl
0MC2Hb46TpSi125sC8KKfPog88Tk5c0NqMuRkrF8hey1FGlmDoLnzc7ILaZRfyHB
NVOFBkpdn627G190
-----END CERTIFICATE-----'
      end
    end

    trait :with_trusted_expired_chain do
      # This contains
      # Let's Encrypt Authority X3
      # DST Root CA X3
      certificate do
        '-----BEGIN CERTIFICATE-----
MIIFSjCCBDKgAwIBAgISAw24xGWrFotvTBa6AZI/pzq1MA0GCSqGSIb3DQEBCwUA
MEoxCzAJBgNVBAYTAlVTMRYwFAYDVQQKEw1MZXQncyBFbmNyeXB0MSMwIQYDVQQD
ExpMZXQncyBFbmNyeXB0IEF1dGhvcml0eSBYMzAeFw0xOTAzMDcxNzU5NTZaFw0x
OTA2MDUxNzU5NTZaMBQxEjAQBgNVBAMTCXN5dHNlLmNvbTCCASIwDQYJKoZIhvcN
AQEBBQADggEPADCCAQoCggEBALtIpQuqeZN6OgEE+y2UoGC/31Vt9NAeQWvTuWWO
nMn/MvDJiw8731Dx4DDbMjhF50UBE20a9iAu2nhlxcsuuIITk2MXKMEgPtqSbwM7
Mg0/WvgrBOWnF9CpdD3qcsjtstT6Djij06VfMfUrRZzMkGgbGzudR0cShKPmkBVU
LgB6crFmSQ/qHt5PzBivdexCUpz5WzSKU5UWYFx2UnkSLykvEJuUr3Nn4/o9oyKw
Qoiq354S262mFuMW+s6wQdMNNkwj41OqCwAGbqq7YUYLDc8OQiRC2LcqSO5yYnnA
0lNfbEatZ1BzHiDjTH7wMUtwcLGHsZ1C5ZmORD2s2gtGiRkCAwEAAaOCAl4wggJa
MA4GA1UdDwEB/wQEAwIFoDAdBgNVHSUEFjAUBggrBgEFBQcDAQYIKwYBBQUHAwIw
DAYDVR0TAQH/BAIwADAdBgNVHQ4EFgQUAMn3t1s4zXdOQbJFOP1riSwjuGkwHwYD
VR0jBBgwFoAUqEpqYwR93brm0Tm3pkVl7/Oo7KEwbwYIKwYBBQUHAQEEYzBhMC4G
CCsGAQUFBzABhiJodHRwOi8vb2NzcC5pbnQteDMubGV0c2VuY3J5cHQub3JnMC8G
CCsGAQUFBzAChiNodHRwOi8vY2VydC5pbnQteDMubGV0c2VuY3J5cHQub3JnLzAU
BgNVHREEDTALgglzeXRzZS5jb20wTAYDVR0gBEUwQzAIBgZngQwBAgEwNwYLKwYB
BAGC3xMBAQEwKDAmBggrBgEFBQcCARYaaHR0cDovL2Nwcy5sZXRzZW5jcnlwdC5v
cmcwggEEBgorBgEEAdZ5AgQCBIH1BIHyAPAAdQB0ftqDMa0zEJEhnM4lT0Jwwr/9
XkIgCMY3NXnmEHvMVgAAAWlZhr4pAAAEAwBGMEQCIBEA+3oiM1UJKY1kajBO5Aoz
9AZMMlImaR1X5hFIPr95AiBXGIACuXUDLchB0kT8VIG/jM4f9iuXMoYCoKNJggNM
/gB3ACk8UZZUyDlluqpQ/FgH1Ldvv1h6KXLcpMMM9OVFR/R4AAABaVmGv/AAAAQD
AEgwRgIhANeTA7H51SZUmcT2ldtumFYX6/OkOr0fdvze72U0j9U9AiEAjSOSVQmi
ZdYK6u3JYkDVOWsEzyKwjPWod8UN5K3ej0EwDQYJKoZIhvcNAQELBQADggEBAJev
ArtxZVVTmLghV0O7471J1mN1fVC2p6b3AsK/TqrI7aiq8XuQq76KmUsB+U05MTXH
3sYiHm+/RJ7+ljiKVIC8ZfbQsHo5I+F1CNMo6JB6z8Z+bOeRkoves5FNYmiJnUjO
uoGzt//CyldbX1dEPVNuU7P0s2wZ6Bubump2LoapGIiGxQJfeb0vj0TQzfRacTIZ
x9U5E/D0y0iewX4kPHK17QDBsSL9WlqsRzFAkQjJ9XWUVn3BO7JG3WU47iOuykby
y2HmOWUxjv1Yf/H/OYRBiuSCR4LhrE5Ze4tTo2AByrXQ5h7ezjDJQqnKBP5NuwIq
7NuX+D2esUNos/D6uJg=
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
MIIEkjCCA3qgAwIBAgIQCgFBQgAAAVOFc2oLheynCDANBgkqhkiG9w0BAQsFADA/
MSQwIgYDVQQKExtEaWdpdGFsIFNpZ25hdHVyZSBUcnVzdCBDby4xFzAVBgNVBAMT
DkRTVCBSb290IENBIFgzMB4XDTE2MDMxNzE2NDA0NloXDTIxMDMxNzE2NDA0Nlow
SjELMAkGA1UEBhMCVVMxFjAUBgNVBAoTDUxldCdzIEVuY3J5cHQxIzAhBgNVBAMT
GkxldCdzIEVuY3J5cHQgQXV0aG9yaXR5IFgzMIIBIjANBgkqhkiG9w0BAQEFAAOC
AQ8AMIIBCgKCAQEAnNMM8FrlLke3cl03g7NoYzDq1zUmGSXhvb418XCSL7e4S0EF
q6meNQhY7LEqxGiHC6PjdeTm86dicbp5gWAf15Gan/PQeGdxyGkOlZHP/uaZ6WA8
SMx+yk13EiSdRxta67nsHjcAHJyse6cF6s5K671B5TaYucv9bTyWaN8jKkKQDIZ0
Z8h/pZq4UmEUEz9l6YKHy9v6Dlb2honzhT+Xhq+w3Brvaw2VFn3EK6BlspkENnWA
a6xK8xuQSXgvopZPKiAlKQTGdMDQMc2PMTiVFrqoM7hD8bEfwzB/onkxEz0tNvjj
/PIzark5McWvxI0NHWQWM6r6hCm21AvA2H3DkwIDAQABo4IBfTCCAXkwEgYDVR0T
AQH/BAgwBgEB/wIBADAOBgNVHQ8BAf8EBAMCAYYwfwYIKwYBBQUHAQEEczBxMDIG
CCsGAQUFBzABhiZodHRwOi8vaXNyZy50cnVzdGlkLm9jc3AuaWRlbnRydXN0LmNv
bTA7BggrBgEFBQcwAoYvaHR0cDovL2FwcHMuaWRlbnRydXN0LmNvbS9yb290cy9k
c3Ryb290Y2F4My5wN2MwHwYDVR0jBBgwFoAUxKexpHsscfrb4UuQdf/EFWCFiRAw
VAYDVR0gBE0wSzAIBgZngQwBAgEwPwYLKwYBBAGC3xMBAQEwMDAuBggrBgEFBQcC
ARYiaHR0cDovL2Nwcy5yb290LXgxLmxldHNlbmNyeXB0Lm9yZzA8BgNVHR8ENTAz
MDGgL6AthitodHRwOi8vY3JsLmlkZW50cnVzdC5jb20vRFNUUk9PVENBWDNDUkwu
Y3JsMB0GA1UdDgQWBBSoSmpjBH3duubRObemRWXv86jsoTANBgkqhkiG9w0BAQsF
AAOCAQEA3TPXEfNjWDjdGBX7CVW+dla5cEilaUcne8IkCJLxWh9KEik3JHRRHGJo
uM2VcGfl96S8TihRzZvoroed6ti6WqEBmtzw3Wodatg+VyOeph4EYpr/1wXKtx8/
wApIvJSwtmVi4MFU5aMqrSDE6ea73Mj2tcMyo5jMd6jmeWUHK8so/joWUoHOUgwu
X4Po1QYz+3dszkDqMp4fklxBwXRsW10KXzPMTZ+sOPAveyxindmjkW8lGy+QsRlG
PfZ+G6Z6h7mjem0Y+iWlkYcV4PIWL1iwBi8saCbGS5jN2p8M+X+Q7UNKEkROb3N6
KOqkqm57TH2H3eDJAkSnh6/DNFu0Qg==
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
MIIDSjCCAjKgAwIBAgIQRK+wgNajJ7qJMDmGLvhAazANBgkqhkiG9w0BAQUFADA/
MSQwIgYDVQQKExtEaWdpdGFsIFNpZ25hdHVyZSBUcnVzdCBDby4xFzAVBgNVBAMT
DkRTVCBSb290IENBIFgzMB4XDTAwMDkzMDIxMTIxOVoXDTIxMDkzMDE0MDExNVow
PzEkMCIGA1UEChMbRGlnaXRhbCBTaWduYXR1cmUgVHJ1c3QgQ28uMRcwFQYDVQQD
Ew5EU1QgUm9vdCBDQSBYMzCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEB
AN+v6ZdQCINXtMxiZfaQguzH0yxrMMpb7NnDfcdAwRgUi+DoM3ZJKuM/IUmTrE4O
rz5Iy2Xu/NMhD2XSKtkyj4zl93ewEnu1lcCJo6m67XMuegwGMoOifooUMM0RoOEq
OLl5CjH9UL2AZd+3UWODyOKIYepLYYHsUmu5ouJLGiifSKOeDNoJjj4XLh7dIN9b
xiqKqy69cK3FCxolkHRyxXtqqzTWMIn/5WgTe1QLyNau7Fqckh49ZLOMxt+/yUFw
7BZy1SbsOFU5Q9D8/RhcQPGX69Wam40dutolucbY38EVAjqr2m7xPi71XAicPNaD
aeQQmxkqtilX4+U9m5/wAl0CAwEAAaNCMEAwDwYDVR0TAQH/BAUwAwEB/zAOBgNV
HQ8BAf8EBAMCAQYwHQYDVR0OBBYEFMSnsaR7LHH62+FLkHX/xBVghYkQMA0GCSqG
SIb3DQEBBQUAA4IBAQCjGiybFwBcqR7uKGY3Or+Dxz9LwwmglSBd49lZRNI+DT69
ikugdB/OEIKcdBodfpga3csTS7MgROSR6cz8faXbauX+5v3gTt23ADq1cEmv8uXr
AvHRAosZy5Q6XkjEGB5YGV8eAlrwDPGxrancWYaLbumR9YbK+rlmM6pZW87ipxZz
R8srzJmwN0jP41ZL9c8PDHIyh8bwRLtTcm1D9SZImlJnt1ir/md2cXjbDaJWFBM5
JDGFoqgCWjBH4d1QB7wCCZAA62RjYJsWvIjJEubSfZGL+T0yjWW06XyxV3bqxbYo
Ob8VZRzI9neWagqNdwvYkQsEjgfbKbYK7p2CNTUQ
-----END CERTIFICATE-----'
      end
    end

    trait :with_expired_certificate do
      certificate do
        '-----BEGIN CERTIFICATE-----
MIIBsDCCARmgAwIBAgIBATANBgkqhkiG9w0BAQUFADAeMRwwGgYDVQQDExNleHBp
cmVkLWNlcnRpZmljYXRlMB4XDTE1MDIxMjE0MzMwMFoXDTE2MDIwMTE0MzMwMFow
HjEcMBoGA1UEAxMTZXhwaXJlZC1jZXJ0aWZpY2F0ZTCBnzANBgkqhkiG9w0BAQEF
AAOBjQAwgYkCgYEApL4J9L0ZxFJ1hI1LPIflAlAGvm6ZEvoT4qKU5Xf2JgU7/2ge
NR1qlNFaSvCc08Knupp5yTgmvyK/Xi09U0N82vvp4Zvr/diSc4A/RA6Mta6egLyS
NT438kdTnY2tR5feoTLwQpX0t4IMlwGQGT5h6Of2fKmDxzuwuyffcIHqLdsCAwEA
ATANBgkqhkiG9w0BAQUFAAOBgQBNj+vWvneyW1KkbVK+b/cVmnYPSfbkHrYK6m8X
Hq9LkWn6WP4EHsesHyslgTQZF8C7kVLTbLn2noLnOE+Mp3vcWlZxl3Yk6aZMhKS+
Iy6oRpHaCF/2obZdIdgf9rlyz0fkqyHJc9GkioSoOhJZxEV2SgAkap8yS0sX2tJ9
ZDXgrA==
-----END CERTIFICATE-----'
      end
    end

    trait :letsencrypt do
      auto_ssl_enabled { true }
      certificate_source { :gitlab_provided }
    end

    trait :explicit_ecdsa do
      certificate do
        '-----BEGIN CERTIFICATE-----
MIID1zCCAzkCCQDatOIwBlktwjAKBggqhkjOPQQDAjBPMQswCQYDVQQGEwJVUzEL
MAkGA1UECAwCTlkxCzAJBgNVBAcMAk5ZMQswCQYDVQQLDAJJVDEZMBcGA1UEAwwQ
dGVzdC1jZXJ0aWZpY2F0ZTAeFw0xOTA4MjkxMTE1NDBaFw0yMTA4MjgxMTE1NDBa
ME8xCzAJBgNVBAYTAlVTMQswCQYDVQQIDAJOWTELMAkGA1UEBwwCTlkxCzAJBgNV
BAsMAklUMRkwFwYDVQQDDBB0ZXN0LWNlcnRpZmljYXRlMIICXDCCAc8GByqGSM49
AgEwggHCAgEBME0GByqGSM49AQECQgH/////////////////////////////////
/////////////////////////////////////////////////////zCBngRCAf//
////////////////////////////////////////////////////////////////
///////////////////8BEFRlT65YY4cmh+SmiGgtoVA7qLacluZsxXzuLSJkY7x
CeFWGTlR7H6TexZSwL07sb8HNXPfiD0sNPHvRR/Ua1A/AAMVANCeiAApHLhTlsxn
FzkyhKqg2mS6BIGFBADGhY4GtwQE6c2ePstmI5W0QpxkgTkFP7Uh+CivYGtNPbqh
S1537+dZKP4dwSei/6jeM0izwYVqQpv5fn4xwuW9ZgEYOSlqeJo7wARcil+0LH0b
2Zj1RElXm0RoF6+9Fyc+ZiyX7nKZXvQmQMVQuQE/rQdhNTxwhqJywkCIvpR2n9Fm
UAJCAf//////////////////////////////////////////+lGGh4O/L5Zrf8wB
SPcJpdA7tcm4iZxHrrtvtx6ROGQJAgEBA4GGAAQBVG/4c/hgl36toHj+eGL4pqv7
l7M+ZKQJ4vz0Y9E6xIx+gvfVaZ58krmbBAP53ikwneQbFdcvw3L/ACPEib/qWjkB
ogykguy3OwHtKLYNnDWIsfiLumEjElhcBMZVXiXhb5txf11uXAWn5n6Qhey5YKPM
NjLLqDqaG19efCLCd21A0TcwCgYIKoZIzj0EAwIDgYsAMIGHAkEm68kYFVnN1c2N
OjSJpIDdFWGVYJHyMDI5WgQyhm4hAioXJ0T22Zab8Wmq+hBYRJNcHoaV894blfqR
V3ZJgam8EQJCAcnPpJQ0IqoT1pAQkaL3+Ka8ZaaCd6/8RnoDtGvWljisuyH65SRu
kmYv87bZe1KqOZDoaDBdfVsoxcGbik19lBPV
-----END CERTIFICATE-----'
      end

      key do
        '-----BEGIN EC PARAMETERS-----
MIIBwgIBATBNBgcqhkjOPQEBAkIB////////////////////////////////////
//////////////////////////////////////////////////8wgZ4EQgH/////
////////////////////////////////////////////////////////////////
/////////////////ARBUZU+uWGOHJofkpohoLaFQO6i2nJbmbMV87i0iZGO8Qnh
Vhk5Uex+k3sWUsC9O7G/BzVz34g9LDTx70Uf1GtQPwADFQDQnogAKRy4U5bMZxc5
MoSqoNpkugSBhQQAxoWOBrcEBOnNnj7LZiOVtEKcZIE5BT+1Ifgor2BrTT26oUte
d+/nWSj+HcEnov+o3jNIs8GFakKb+X5+McLlvWYBGDkpaniaO8AEXIpftCx9G9mY
9URJV5tEaBevvRcnPmYsl+5ymV70JkDFULkBP60HYTU8cIaicsJAiL6Udp/RZlAC
QgH///////////////////////////////////////////pRhoeDvy+Wa3/MAUj3
CaXQO7XJuImcR667b7cekThkCQIBAQ==
-----END EC PARAMETERS-----
-----BEGIN EC PRIVATE KEY-----
MIICnQIBAQRCAZZRG4FJO+OK29ygycrNzjxQDB+dp+QPo1Pk6RAl5PcraohyhFnI
MGUL4ba1efZUxCbAWxjVRSi7QEUNYCCdUPAtoIIBxjCCAcICAQEwTQYHKoZIzj0B
AQJCAf//////////////////////////////////////////////////////////
////////////////////////////MIGeBEIB////////////////////////////
//////////////////////////////////////////////////////////wEQVGV
PrlhjhyaH5KaIaC2hUDuotpyW5mzFfO4tImRjvEJ4VYZOVHsfpN7FlLAvTuxvwc1
c9+IPSw08e9FH9RrUD8AAxUA0J6IACkcuFOWzGcXOTKEqqDaZLoEgYUEAMaFjga3
BATpzZ4+y2YjlbRCnGSBOQU/tSH4KK9ga009uqFLXnfv51ko/h3BJ6L/qN4zSLPB
hWpCm/l+fjHC5b1mARg5KWp4mjvABFyKX7QsfRvZmPVESVebRGgXr70XJz5mLJfu
cple9CZAxVC5AT+tB2E1PHCGonLCQIi+lHaf0WZQAkIB////////////////////
///////////////////////6UYaHg78vlmt/zAFI9wml0Du1ybiJnEeuu2+3HpE4
ZAkCAQGhgYkDgYYABAFUb/hz+GCXfq2geP54Yvimq/uXsz5kpAni/PRj0TrEjH6C
99VpnnySuZsEA/neKTCd5BsV1y/Dcv8AI8SJv+paOQGiDKSC7Lc7Ae0otg2cNYix
+Iu6YSMSWFwExlVeJeFvm3F/XW5cBafmfpCF7Llgo8w2MsuoOpobX158IsJ3bUDR
Nw==
-----END EC PRIVATE KEY-----'
      end
    end

    trait :ecdsa do
      certificate do
        '-----BEGIN CERTIFICATE-----
MIIB8zCCAVUCCQCGKuPQ6SBxUTAKBggqhkjOPQQDAjA+MQswCQYDVQQGEwJVUzEL
MAkGA1UECAwCVVMxCzAJBgNVBAcMAlVTMRUwEwYDVQQDDAxzaHVzaGxpbi5kZXYw
HhcNMTkwOTAyMDkyMDUxWhcNMjEwOTAxMDkyMDUxWjA+MQswCQYDVQQGEwJVUzEL
MAkGA1UECAwCVVMxCzAJBgNVBAcMAlVTMRUwEwYDVQQDDAxzaHVzaGxpbi5kZXYw
gZswEAYHKoZIzj0CAQYFK4EEACMDgYYABAH9Jd7ZWnTasgltZRbIMreihycOh/G4
TXpkp8tTtEsuD+sh8au3Jywsi89RSZ6vgVoCY7//DQ2vamYnyBZqbL+cTQBsQ7wD
UEaSyP0R3P4b6Ox347pYzXwSdSOra9Cm4TMQe+prVMesxulqIm7G7CTI+9J8LHlJ
z0wUDQz/o+tUSYwv6zAKBggqhkjOPQQDAgOBiwAwgYcCQUOlTnn2QP/uYSh1dUSl
R9WYUg5+PQMg7kS+4K/5+5gonWCvaMcP+2P7hltUcvq41l3uMKKCZRU/x60/FMHc
1ZXdAkIBuVtm9RJXziNOKS4TcpH9os/FuREW8YQlpec58LDZdlivcHnikHZ4LCri
T7zu3VY6Rq+V/IKpsQwQjmoTJ0IpCM8=
-----END CERTIFICATE-----'
      end

      key do
        '-----BEGIN EC PARAMETERS-----
BgUrgQQAIw==
-----END EC PARAMETERS-----
-----BEGIN EC PRIVATE KEY-----
MIHbAgEBBEFa72+eREW25IHbke0TiWFdW1R1ad9Nyqaz7CDtv5Kqdgd6Kcl8V2az
Lr6z1PS+JSERWzRP+fps7kdFRrtqy/ECpKAHBgUrgQQAI6GBiQOBhgAEAf0l3tla
dNqyCW1lFsgyt6KHJw6H8bhNemSny1O0Sy4P6yHxq7cnLCyLz1FJnq+BWgJjv/8N
Da9qZifIFmpsv5xNAGxDvANQRpLI/RHc/hvo7HfjuljNfBJ1I6tr0KbhMxB76mtU
x6zG6WoibsbsJMj70nwseUnPTBQNDP+j61RJjC/r
-----END EC PRIVATE KEY-----'
      end
    end

    trait :extra_long_key do
      certificate do
        <<~CERT
        -----BEGIN CERTIFICATE-----
        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
        -----END CERTIFICATE-----
        CERT
      end

      key do
        <<~KEY
        -----BEGIN PRIVATE KEY-----
        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
        NtjUPwBEHYJ9bcJ/fgqxWtoc23l/1OfP
        -----END PRIVATE KEY-----
        KEY
      end
    end

    trait :key_length_8192 do
      certificate do
        <<~CERT
        -----BEGIN CERTIFICATE-----
        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
        O5R7
        -----END CERTIFICATE-----
        CERT
      end

      key do
        <<~KEY
        -----BEGIN PRIVATE KEY-----
        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
        c5RerXbZTDEafdHsyGlkhu+nOjYvyGM=
        -----END PRIVATE KEY-----
        KEY
      end
    end

    trait :instance_serverless do
      wildcard { true }
      scope { :instance }
      usage { :serverless }
    end

    trait :with_project do
      association :project
    end
  end
end