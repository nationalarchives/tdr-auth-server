import base64url from "base64url"

export default class WebAuthn {
  credentials: CredentialsContainer

  constructor(credentials?: CredentialsContainer) {
    if (credentials) {
      this.credentials = credentials
    } else {
      this.credentials = window.navigator.credentials
    }
  }

  setInputValue(id: string, value: string): void {
    const input: HTMLInputElement | null = document.querySelector(`#${id}`)
    if (input) {
      input.value = value
    }
  }

  getValueFromInput(id: string): string {
    const input: HTMLInputElement | null = document.querySelector(`#${id}`)
    if (input) {
      return input.value
    } else {
      throw `input element with id ${id} is missing`
    }
  }

  checkIfWebAuthnSupported() {
    if (!window.PublicKeyCredential) {
      const unsupportedMessage = this.getValueFromInput("unsupported-browser-message")
      this.setInputValue("error", unsupportedMessage)
      const form: HTMLFormElement | null = document.querySelector("#register")
      if (form) {
        form.submit()
      }
    }
  }

  public webAuthnAuthenticate(authenticate: (publicKey: PublicKeyCredentialRequestOptions) => void): void {

    const getAuthenticatePublicKey: (allowCredentials: PublicKeyCredentialDescriptor[]) => PublicKeyCredentialRequestOptions  = allowCredentials => {
      this.checkIfWebAuthnSupported()

      const getUserVerification: () => UserVerificationRequirement | null = () => {
        const verification = this.getValueFromInput("userVerification")
        if (verification == "not specified") {
          return null
        } else {
          return verification as UserVerificationRequirement
        }
      }

      const challenge = this.getValueFromInput("challenge")
      const createTimeout = parseInt(this.getValueFromInput("createTimeout"), 10)

      let publicKey: PublicKeyCredentialRequestOptions = {
        rpId: this.getValueFromInput("rpId"),
        challenge: new Uint8Array(base64url.toBuffer(challenge))
      }

      if (createTimeout !== 0) publicKey.timeout = createTimeout * 1000

      if (allowCredentials.length) {
        publicKey.allowCredentials = allowCredentials
      }

      const userVerification = getUserVerification()
      if (userVerification) {
        publicKey.userVerification = userVerification
      }
      return publicKey
    }

    let isUserIdentified = this.getValueFromInput("isUserIdentified")
    if (!isUserIdentified) {
      authenticate(getAuthenticatePublicKey([]))
      return
    }
    let allowCredentials: PublicKeyCredentialDescriptor[] = []
    const useCheckElements: HTMLCollectionOf<Element> = document.getElementsByClassName("authn_use_check")
    for (const authnUseCheck of useCheckElements) {
      allowCredentials.push({
        id: new Uint8Array(base64url.toBuffer((authnUseCheck as HTMLInputElement).value)),
        type: 'public-key',
      })
    }
    authenticate(getAuthenticatePublicKey(allowCredentials))
  }

  doAuthenticate(publicKey: PublicKeyCredentialRequestOptions): void {
    this.credentials.get({publicKey})
      .then((result: Credential | null) => {
        if (result) {
          (window as any).result = result
          if ("response" in result) {
            const credentialType = result as PublicKeyCredential
            const response: AuthenticatorAssertionResponse = credentialType.response as AuthenticatorAssertionResponse
            let clientDataJSON = response.clientDataJSON
            let authenticatorData = response.authenticatorData
            let signature = response.signature
            this.setInputValue("clientDataJSON", base64url.encode(new Buffer(clientDataJSON)))
            this.setInputValue("authenticatorData", base64url.encode(new Buffer(authenticatorData)))
            this.setInputValue("signature", base64url.encode(new Buffer(signature)))
            this.setInputValue("credentialId", credentialType.id)
            if (response.userHandle) {
              this.setInputValue("userHandle", base64url.encode(new Buffer(response.userHandle)))
            }
            const webAuth: HTMLFormElement | null = document.querySelector("#webAuth")
            if (webAuth) {
              webAuth.submit()
            }
          }
        }
      })
      .catch((err) => {
        this.setInputValue("error", err)
        const webAuth: HTMLFormElement | null = document.querySelector("#webAuth")
        if (webAuth) {
          webAuth.submit()
        }
      })
  }

  submitRegisterForm: () => void = () => {
    const registerForm: HTMLFormElement | null = document.querySelector("#register")
    if (registerForm) {
      registerForm.submit()
    }
  }

  getCreationPublicKey(): PublicKeyCredentialCreationOptions {
    const getPubKeyCredParams: (signatureAlgorithms: string) => PublicKeyCredentialParameters[] = signatureAlgorithms => {
      if (signatureAlgorithms === "") {
        return [{type: "public-key", alg: -7}]
      }
      return signatureAlgorithms.split(',').map(alg => ({
        type: "public-key",
        alg: parseInt(alg, 10)
      }))
    }

    const challenge = this.getValueFromInput("challenge")
    const userid = this.getValueFromInput("userid")
    const username = this.getValueFromInput("username")
    const signatureAlgorithms = this.getValueFromInput("signatureAlgorithms")
    const name = this.getValueFromInput("rpEntityName")
    const pubKeyCredParams: PublicKeyCredentialParameters[] = getPubKeyCredParams(signatureAlgorithms)
    const rp: PublicKeyCredentialRpEntity = {name}
    const publicKey: PublicKeyCredentialCreationOptions = {
      challenge: new Uint8Array(base64url.toBuffer(challenge)),
      rp,
      user: {
        id: new Uint8Array(base64url.toBuffer(userid)),
        name: username,
        displayName: username
      },
      pubKeyCredParams: pubKeyCredParams,
    }

    publicKey.rp.id = this.getValueFromInput("rpId")

    const getAttestationConveyancePreference: () => AttestationConveyancePreference | null = () => {
      const attestation = this.getValueFromInput("attestationConveyancePreference")
      if (attestation == "not specified") {
        return null
      } else {
        return attestation as AttestationConveyancePreference
      }
    }

    const attestationConveyancePreference = getAttestationConveyancePreference()
    if (attestationConveyancePreference) {
      publicKey.attestation = attestationConveyancePreference
    }

    const authenticatorSelection: AuthenticatorSelectionCriteria = {}
    let isAuthenticatorSelectionSpecified = false

    const getAuthenticatorAttachment: () => AuthenticatorAttachment | null = () => {
      const attachment = this.getValueFromInput("authenticatorAttachment")
      if (attachment == "not specified") {
        return null
      } else {
        return attachment as AuthenticatorAttachment
      }
    }

    const getUserVerificationRequirement: () => UserVerificationRequirement | null = () => {
      const requirement = this.getValueFromInput("userVerificationRequirement")
      if (requirement == "not specified") {
        return null
      } else {
        return requirement as UserVerificationRequirement
      }
    }

    const authenticatorAttachment = getAuthenticatorAttachment()
    if (authenticatorAttachment) {
      authenticatorSelection.authenticatorAttachment = authenticatorAttachment
      isAuthenticatorSelectionSpecified = true
    }

    const requireResidentKey = this.getValueFromInput("requireResidentKey")
    if (requireResidentKey !== 'not specified') {
      authenticatorSelection.requireResidentKey = requireResidentKey === 'Yes';
      isAuthenticatorSelectionSpecified = true
    }

    const userVerificationRequirement = getUserVerificationRequirement()
    if (userVerificationRequirement) {
      authenticatorSelection.userVerification = userVerificationRequirement
      isAuthenticatorSelectionSpecified = true
    }

    if (isAuthenticatorSelectionSpecified) publicKey.authenticatorSelection = authenticatorSelection

    const createTimeout = parseInt(this.getValueFromInput("createTimeout"), 10)
    if (createTimeout !== 0) publicKey.timeout = createTimeout * 1000

    const excludeCredentialIds = this.getValueFromInput("excludeCredentialIds")
    const excludeCredentials: PublicKeyCredentialDescriptor[] = excludeCredentialIds.split(",").map(id => ({
      type: "public-key",
      id: new Uint8Array(base64url.toBuffer(id))
    }))
    if (excludeCredentials.length > 0) publicKey.excludeCredentials = excludeCredentials

    return publicKey
  }

  public registerSecurityKey(publicKey: PublicKeyCredentialCreationOptions): void {

    // Check if WebAuthn is supported by this browser
    this.checkIfWebAuthnSupported()

    this.credentials.create({publicKey})
      .then((result: Credential | null) => {
        if (result) {
          (window as any).result = result
          if ("response" in result) {
            const credentialType = result as PublicKeyCredential
            const response = credentialType.response as AuthenticatorAttestationResponse
            const clientDataJSON = response.clientDataJSON
            const attestationObject = response.attestationObject
            const publicKeyCredentialId = credentialType.rawId

            this.setInputValue("clientDataJSON", base64url.encode(new Buffer(clientDataJSON)))
            this.setInputValue("attestationObject", base64url.encode(new Buffer(attestationObject)))
            this.setInputValue("publicKeyCredentialId", base64url.encode(new Buffer(publicKeyCredentialId)))
            const initLabel = "WebAuthn Authenticator (Default Label)"
            let labelResult = window.prompt("Please input your registered authenticator's label", initLabel)
            if (labelResult === null) labelResult = initLabel
            this.setInputValue("authenticatorLabel", labelResult)
            this.submitRegisterForm()
          }
        }
      })
      .catch((err) => {
        const errorElement: HTMLInputElement | null = document.querySelector("#error")
        errorElement!.value = err
        this.submitRegisterForm()
      })
  }
}
