import WebAuthn from "../src/webauthn";
import base64url from "base64url"

window.prompt = (message?: string, _default?: string) => {
  return null
}

const commonCredentialValues = {
  preventSilentAccess: jest.fn(),
  requireUserMediation: jest.fn(),
  store: jest.fn()
}

const credentialsCreate: (publicKey: Promise<CredentialType | null>) => CredentialsContainer = publicKey => ({
  create(_?: CredentialCreationOptions): Promise<CredentialType | null> {
    return publicKey
  },
  get: jest.fn(),
  ...commonCredentialValues
})

const credentialsGet: (publicKey: Promise<CredentialType | null>) => CredentialsContainer = publicKey => ({
  create: jest.fn(),
  get(_?: CredentialRequestOptions): Promise<CredentialType | null> {
    return publicKey
  },
  ...commonCredentialValues
})

const authenticatorAssertionResponse: (authenticatorData: ArrayBuffer, clientDataJSON: ArrayBuffer, signature: ArrayBuffer, userHandle: ArrayBuffer | null) => AuthenticatorAssertionResponse =  (authenticatorData, clientDataJSON, signature, userHandle) => ({
  authenticatorData,
  clientDataJSON,
  signature,
  userHandle
})

const authenticatorAttestationResponse: (clientDataJSON: ArrayBuffer, attestationObject: ArrayBuffer) => AuthenticatorAttestationResponse = (clientDataJSON, attestationObject) => ({
  attestationObject,
  clientDataJSON,
  getAuthenticatorData: jest.fn(),
  getPublicKey: jest.fn(),
  getPublicKeyAlgorithm: jest.fn(),
  getTransports: jest.fn()
})

const publicKey: (response: AuthenticatorResponse, rawId: ArrayBuffer) => PublicKeyCredential = (response, rawId) => {
  const key: PublicKeyCredential = {
    authenticatorAttachment: "attachment",
    rawId,
    response,
    getClientExtensionResults: jest.fn(),
    id: "id",
    type: "public-key",
    toJSON: jest.fn()
  }
  return key
}

const options: PublicKeyCredentialCreationOptions = {
  challenge: new Uint8Array(0),
  excludeCredentials: [],
  pubKeyCredParams: [],
  rp: {id: "", name: ""},
  user: {id: new Uint8Array(0), name: "", displayName: ""}
}

const createInputElement: (id: string, value?: string) => HTMLInputElement = (id, value) => {
  const element = document.createElement("input") as HTMLInputElement
  element.id = id
  if (value) {
    element.value = value
  }
  document.body.appendChild(element)
  return element
}

const checkValue: (id: string, value: string) => void = (id, value) => {
  const element: HTMLInputElement | null = document.querySelector(`#${id}`)
  expect(element).not.toBeNull()
  expect(element!.value).toEqual(value)
}

const resetElement: (id: string) => void = id => {
  const errorElement: HTMLInputElement | null = document.querySelector(`#${id}`)
  if (errorElement) {
    errorElement.value = ""
  }
}

beforeAll(() => {
  createInputElement("challenge")
  createInputElement("createTimeout")
  createInputElement("error")
})

test("checkIfWebAuthnSupported should set an error message if webauthn is not supported ", () => {
  const message = "Unsupported browser"
  createInputElement("unsupported-browser-message", message)
  new WebAuthn().checkIfWebAuthnSupported()
  const errorMsg = (document.querySelector("#error") as HTMLInputElement).value
  expect(errorMsg).toEqual(message)
})

test("checkIfWebAuthnSupported should not set an error message if webauthn is supported ", () => {
  Object.defineProperty(global.window, 'PublicKeyCredential', {value: {}})
  resetElement("error")
  const message = "Unsupported browser"
  createInputElement("unsupported-browser-message", message)
  new WebAuthn().checkIfWebAuthnSupported()
  const errorMsg = (document.querySelector("#error") as HTMLInputElement).value
  expect(errorMsg).toEqual("")
})

test("registerSecurityKey sets the correct form values", async () => {
  createInputElement("unsupported-browser-message", "unsupported")
  createInputElement("clientDataJSON")
  createInputElement("attestationObject")
  createInputElement("publicKeyCredentialId")
  createInputElement("authenticatorLabel")

  const clientDataJSON = new Uint8Array(Buffer.from("clientDataJSON")).buffer
  const attestationObject = new Uint8Array(Buffer.from("attestationObject")).buffer
  const rawId = new Uint8Array(Buffer.from("rawId")).buffer

  const key = publicKey(authenticatorAttestationResponse(clientDataJSON, attestationObject), rawId)
  new WebAuthn(credentialsCreate(Promise.resolve(key))).registerSecurityKey(options)
  await new Promise(process.nextTick);

  checkValue("clientDataJSON", base64url.encode(Buffer.from(clientDataJSON)))
  checkValue("attestationObject", base64url.encode(Buffer.from(attestationObject)))
  checkValue("publicKeyCredentialId", base64url.encode(Buffer.from(rawId)))
  checkValue("authenticatorLabel", "WebAuthn Authenticator (Default Label)")
})

test("registerSecurityKey sets the error message if there is an error", async () => {
  const errorMessage = "Test Error Message"
  new WebAuthn(credentialsCreate(Promise.reject(errorMessage))).registerSecurityKey(options)
  await new Promise(process.nextTick);
  checkValue("error", errorMessage)
})

test("getCreationPublicKey returns public key creation options", () => {
  const userId = "userid"
  const userName = "username"
  const rpEntityName = "rpEntityName"
  const attestationConveyancePreference = "direct"
  const authenticatorAttachment = "platform"
  const rpId = "rpId"
  const requireResidentKey = "Yes"
  const userVerificationRequirement = "preferred"
  const excludeCredentialIds = "excludeCredentialIds"

  createInputElement("userid", userId)
  createInputElement("username", userName)
  createInputElement("signatureAlgorithms", "-7,-6")
  createInputElement("rpEntityName", rpEntityName)
  createInputElement("rpId", rpId)
  createInputElement("attestationConveyancePreference", attestationConveyancePreference)
  createInputElement("authenticatorAttachment", authenticatorAttachment)
  createInputElement("requireResidentKey", requireResidentKey)
  createInputElement("userVerificationRequirement", userVerificationRequirement)
  createInputElement("excludeCredentialIds", excludeCredentialIds)

  const webAuthn = new WebAuthn(credentialsCreate(Promise.resolve(null)))
  const publicKey = webAuthn.getCreationPublicKey()

  expect(publicKey.pubKeyCredParams).toEqual([{type: 'public-key', alg: -7}, {type: 'public-key', alg: -6}])
  expect(publicKey.user.id).toEqual(base64url.toBuffer(userId))
  expect(publicKey.user.name).toEqual(userName)
  expect(publicKey.user.displayName).toEqual(userName)
  expect(publicKey.rp.name).toEqual(rpEntityName)
  expect(publicKey.attestation).toEqual(attestationConveyancePreference)
  expect(publicKey.authenticatorSelection!.authenticatorAttachment).toEqual(authenticatorAttachment)
  expect(publicKey.authenticatorSelection!.requireResidentKey).toEqual(true)
  expect(publicKey.authenticatorSelection!.userVerification).toEqual(userVerificationRequirement)
  expect(publicKey.excludeCredentials).toEqual([{type: "public-key", id: base64url.toBuffer(excludeCredentialIds)}])
  expect(publicKey.rp.id).toEqual(rpId)
})

test("doAuthenticate sets the correct form values", async () => {
  createInputElement("clientDataJSON")
  createInputElement("authenticatorData")
  createInputElement("signature")
  createInputElement("credentialId")
  createInputElement("userHandle")

  // Convert to ArrayBuffer by creating Uint8Array from Buffer and accessing .buffer
  const clientDataJSON = new Uint8Array(Buffer.from("clientDataJSON")).buffer
  const signature = new Uint8Array(Buffer.from("signature")).buffer
  const authenticatorData = new Uint8Array(Buffer.from("authenticatorData")).buffer
  const userHandle = new Uint8Array(Buffer.from("userHandle")).buffer
  const rawId = new Uint8Array(Buffer.from("rawId")).buffer

  const response = authenticatorAssertionResponse(authenticatorData, clientDataJSON, signature, userHandle)
  const key = publicKey(response, rawId)
  new WebAuthn(credentialsGet(Promise.resolve(key))).doAuthenticate(options)
  await new Promise(process.nextTick);

  checkValue("clientDataJSON", base64url.encode(Buffer.from(clientDataJSON)))
  checkValue("authenticatorData", base64url.encode(Buffer.from(authenticatorData)))
  checkValue("signature", base64url.encode(Buffer.from(signature)))
  checkValue("credentialId", key.id)
  checkValue("userHandle", base64url.encode(Buffer.from(userHandle)))
})

test("doAuthenticate sets the error message if there is an error", async () => {
  const errorMessage = "doAuthenticate error"
  new WebAuthn(credentialsGet(Promise.reject(errorMessage))).doAuthenticate(options)
  await new Promise(process.nextTick);
  checkValue("error", errorMessage)
})

test("webAuthnAuthenticate calls the authenticate function with the correct credentials if user is identified", () => {
  const authFunction = jest.fn()
  const userVerification = "preferred"
  const rpId = "rpId"
  const id = "id"

  const useCheck = document.createElement("input")
  useCheck.className = "authn_use_check"
  useCheck.value = id
  document.body.appendChild(useCheck)

  createInputElement("unsupported-browser-message", "unsupported")
  createInputElement("isUserIdentified", "Yes")
  createInputElement("userVerification", userVerification)
  createInputElement("rpId", rpId)

  new WebAuthn(credentialsCreate(Promise.resolve(null))).webAuthnAuthenticate(authFunction)
  const key: PublicKeyCredentialRequestOptions = authFunction.mock.calls[0][0]
  expect(key.rpId).toEqual(rpId)
  expect(key.userVerification).toEqual(userVerification )
  expect(key.allowCredentials!.length).toEqual(1)
  expect(key.allowCredentials![0].id).toEqual(base64url.toBuffer(id))
})

test("webAuthnAuthenticate calls the authenticate function with the correct credentials if user is not identified", () => {
  const authFunction = jest.fn()
  const userVerification = "preferred"
  const rpId = "rpId"

  createInputElement("unsupported-browser-message", "unsupported")
  createInputElement("userVerification", userVerification)
  createInputElement("rpId", rpId)
  resetElement("isUserIdentified")

  new WebAuthn(credentialsCreate(Promise.resolve(null))).webAuthnAuthenticate(authFunction)
  const key: PublicKeyCredentialRequestOptions = authFunction.mock.calls[0][0]
  expect(key.rpId).toEqual(rpId)
  expect(key.userVerification).toEqual(userVerification)
  expect(key.allowCredentials).toBeUndefined()
})
