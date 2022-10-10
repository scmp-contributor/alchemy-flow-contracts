import NonFungibleToken from 0x1d7e57aa55817448
import ARTIFACTPack from 0x24de869c5e40b2eb
import ARTIFACT from 0x24de869c5e40b2eb
import ARTIFACTPackV3 from 0x24de869c5e40b2eb
import ARTIFACTV2 from 0x24de869c5e40b2eb
import ARTIFACTViews from 0x24de869c5e40b2eb

pub struct NFTCollection {
    pub let owner: Address
    pub let nfts: [NFTData]

    init(owner: Address) {
        self.owner = owner
        self.nfts = []
    }
}

pub struct NFTData {
    pub let contract: NFTContractData
    pub let id: UInt64
    pub let uuid: UInt64?
    pub let title: String?
    pub let description: String?
    pub let external_domain_view_url: String?
    pub let token_uri: String?
    pub let media: [NFTMedia?]
    pub let metadata: {String: String?}

    init(
        contract: NFTContractData,
        id: UInt64,
        uuid: UInt64?,
        title: String?,
        description: String?,
        external_domain_view_url: String?,
        token_uri: String?,
        media: [NFTMedia?],
        metadata: {String: String?}
    ) {
        self.contract = contract
        self.id = id
        self.uuid = uuid
        self.title = title
        self.description = description
        self.external_domain_view_url = external_domain_view_url
        self.token_uri = token_uri
        self.media = media
        self.metadata = metadata
    }
}

pub struct NFTContractData {
    pub let name: String
    pub let address: Address
    pub let storage_path: String
    pub let public_path: String
    pub let public_collection_name: String
    pub let external_domain: String

    init(
        name: String,
        address: Address,
        storage_path: String,
        public_path: String,
        public_collection_name: String,
        external_domain: String
    ) {
        self.name = name
        self.address = address
        self.storage_path = storage_path
        self.public_path = public_path
        self.public_collection_name = public_collection_name
        self.external_domain = external_domain
    }
}

pub struct NFTMedia {
    pub let uri: String?
    pub let mimetype: String?

    init(
        uri: String?,
        mimetype: String?
    ) {
        self.uri = uri
        self.mimetype = mimetype
    }
}

pub fun main(ownerAddress: Address, ids: {String:[UInt64]}): [NFTData?] {
    let NFTs: [NFTData?] = []
    let owner = getAccount(ownerAddress)

    for key in ids.keys {
        for id in ids[key]! {
            var d: NFTData? = nil

            // note: unfortunately dictonairy containing functions is not
            // working on mainnet for now so we have to fallback to switch
            switch key {
                case "ARTIFACTPack": d = getARTIFACTPack(owner: owner, id: id)
                case "ARTIFACT": d = getARTIFACT(owner: owner, id: id)
                case "ARTIFACTPackV3": d = getARTIFACTPackV3(owner: owner, id: id)
                case "ARTIFACTV2": d = getARTIFACTV2(owner: owner, id: id)
                default:
                    panic("adapter for NFT not found: ".concat(key))
            }

            NFTs.append(d)
        }
    }

    return NFTs
}


// https://flow-view-source.com/mainnet/account/0x24de869c5e40b2eb/contract/ARTIFACT
pub fun getARTIFACT(owner: PublicAccount, id: UInt64): NFTData? {
    let contract = NFTContractData(
        name: "ARTIFACT",
        address: 0x24de869c5e40b2eb,
        storage_path: "ARTIFACT.collectionStoragePath",
        public_path: "ARTIFACT.collectionPublicPath",
        public_collection_name: "ARTIFACT.CollectionPublic",
        external_domain: "https://artifact.scmp.com/",
    )

    let col = owner.getCapability(ARTIFACT.collectionPublicPath)
        .borrow<&{ARTIFACT.CollectionPublic}>()
    if col == nil { return nil }

    let nft = col!.borrow(id: id)
    if nft == nil { return nil }

    var metadata = nft!.data.metadata
    let title = metadata["artifactName"]!
    let description = metadata["artifactShortDescription"]!
    let series = metadata["artifactLookupId"]!

    metadata["editionNumber"] = metadata["artifactEditionNumber"]!
    metadata["editionCount"] = metadata["artifactNumberOfEditions"]!
    metadata["royaltyAddress"] = "0xe9e563d7021d6eda"
    metadata["royaltyPercentage"] = "10.0"
    metadata["rarity"] = metadata["artifactRarityLevel"]!


    let rawMetadata: {String:String?} = {}
    for key in metadata.keys {
        rawMetadata.insert(key: key, metadata[key])
    }

    return NFTData(
        contract: contract,
        id: nft!.id,
        uuid: nft!.uuid,
        title: title,
        description: description,
        external_domain_view_url: "https://artifact.scmp.com/".concat(series),
        token_uri: nil,
        media: [
            NFTMedia(uri: metadata["artifactFileUri"], mimetype: "video/mp4")
        ],
        metadata: rawMetadata
    )
}

// https://flow-view-source.com/mainnet/account/0x24de869c5e40b2eb/contract/ARTIFACTPack
pub fun getARTIFACTPack(owner: PublicAccount, id: UInt64): NFTData? {
    let contract = NFTContractData(
        name: "ARTIFACTPack",
        address: 0x24de869c5e40b2eb,
        storage_path: "ARTIFACTPack.collectionStoragePath",
        public_path: "ARTIFACTPack.collectionPublicPath",
        public_collection_name: "ARTIFACTPack.CollectionPublic",
        external_domain: "https://artifact.scmp.com/",
    )

    let col = owner.getCapability(ARTIFACTPack.collectionPublicPath)
        .borrow<&{ARTIFACTPack.CollectionPublic}>()
    if col == nil { return nil }

    let nft = col!.borrow(id: id)
    if nft == nil {
        return nil
    }

    var description = ""
    var mediaUri = ""

    let isOpen = nft!.isOpen
    var metadata = nft!.metadata
    var series = metadata["lookupId"]!
    var title = metadata["name"]!

    if (isOpen) {
        description = metadata["descriptionOpened"]!
        mediaUri = metadata["fileUriOpened"]!
    } else {
        description = metadata["descriptionUnopened"]!
        mediaUri = metadata["fileUriUnopened"]!
    }

    metadata["editionNumber"] = nft!.edition.toString()
    metadata["editionCount"] = metadata["numberOfEditions"]!
    metadata["royaltyAddress"] = "0xe9e563d7021d6eda"
    metadata["royaltyPercentage"] = "10.0"
    metadata["rarity"] = metadata["rarityLevel"]!

    let rawMetadata: {String:String?} = {}
    for key in metadata.keys {
        rawMetadata.insert(key: key, metadata[key])
    }


    return NFTData(
        contract: contract,
        id: nft!.id,
        uuid: nft!.uuid,
        title: title,
        description: description,
        external_domain_view_url: "https://artifact.scmp.com/".concat(series),
        token_uri: nil,
        media: [
            NFTMedia(uri: mediaUri, mimetype: "image/png")
        ],
        metadata: rawMetadata
    )
}

// https://flow-view-source.com/mainnet/account/0x24de869c5e40b2eb/contract/ARTIFACT
pub fun getARTIFACTV2(owner: PublicAccount, id: UInt64): NFTData? {
    let contract = NFTContractData(
        name: "ARTIFACTV2",
        address: 0x24de869c5e40b2eb,
        storage_path: "ARTIFACTV2.collectionStoragePath",
        public_path: "ARTIFACTV2.collectionPublicPath",
        public_collection_name: "ARTIFACTV2.CollectionPublic",
        external_domain: "https://artifact.scmp.com/",
    )

    let col = owner.getCapability(ARTIFACTV2.collectionPublicPath)
        .borrow<&{ARTIFACTV2.CollectionPublic}>()
    if col == nil { return nil }

    let nft = col!.borrow(id: id)
    if nft == nil { return nil }

    let view = nft!.resolveView(Type<ARTIFACTViews.ArtifactsDisplay>())! as! ARTIFACTViews.ArtifactsDisplay
    var metadata = view.metadata
    let title = metadata["artifactName"]!
    let description = metadata["artifactShortDescription"]!
    let series = metadata["artifactLookupId"]!

    metadata["editionNumber"] = metadata["artifactEditionNumber"]!
    metadata["editionCount"] = metadata["artifactNumberOfEditions"]!
    metadata["royaltyAddress"] = "0xe9e563d7021d6eda"
    metadata["royaltyPercentage"] = "10.0"
    metadata["rarity"] = metadata["artifactRarityLevel"]!


    let rawMetadata: {String:String?} = {}
    for key in metadata.keys {
        rawMetadata.insert(key: key, metadata[key])
    }

    return NFTData(
        contract: contract,
        id: nft!.id,
        uuid: nft!.uuid,
        title: title,
        description: description,
        external_domain_view_url: "https://artifact.scmp.com/".concat(series),
        token_uri: nil,
        media: [
            NFTMedia(uri: metadata["artifactFileUri"], mimetype: "video/mp4")
        ],
        metadata: rawMetadata
    )
}

// https://flow-view-source.com/mainnet/account/0x24de869c5e40b2eb/contract/ARTIFACTPack
pub fun getARTIFACTPackV3(owner: PublicAccount, id: UInt64): NFTData? {
    let contract = NFTContractData(
        name: "ARTIFACTPackV3",
        address: 0x24de869c5e40b2eb,
        storage_path: "ARTIFACTPackV3.collectionStoragePath",
        public_path: "ARTIFACTPackV3.collectionPublicPath",
        public_collection_name: "ARTIFACTPackV3.CollectionPublic",
        external_domain: "https://artifact.scmp.com/",
    )

    let col = owner.getCapability(ARTIFACTPackV3.collectionPublicPath)
        .borrow<&{ARTIFACTPackV3.CollectionPublic}>()
    if col == nil { return nil }

    let nft = col!.borrow(id: id)
    if nft == nil {
        return nil
    }

    var description = ""
    var mediaUri = ""

    let isOpen = nft!.isOpen
    let view = nft!.resolveView(Type<ARTIFACTViews.ArtifactsDisplay>())! as! ARTIFACTViews.ArtifactsDisplay
    var metadata = view.metadata
    var series = metadata["lookupId"]!
    var title = metadata["name"]!

    if (isOpen) {
        description = metadata["descriptionOpened"]!
        mediaUri = metadata["fileUriOpened"]!
    } else {
        description = metadata["descriptionUnopened"]!
        mediaUri = metadata["fileUriUnopened"]!
    }

    metadata["editionNumber"] = nft!.edition.toString()
    metadata["editionCount"] = metadata["numberOfEditions"]!
    metadata["royaltyAddress"] = "0xe9e563d7021d6eda"
    metadata["royaltyPercentage"] = "10.0"
    metadata["rarity"] = metadata["rarityLevel"]!

    let rawMetadata: {String:String?} = {}
    for key in metadata.keys {
        rawMetadata.insert(key: key, metadata[key])
    }


    return NFTData(
        contract: contract,
        id: nft!.id,
        uuid: nft!.uuid,
        title: title,
        description: description,
        external_domain_view_url: "https://artifact.scmp.com/".concat(series),
        token_uri: nil,
        media: [
            NFTMedia(uri: mediaUri, mimetype: "image/png")
        ],
        metadata: rawMetadata
    )
}
