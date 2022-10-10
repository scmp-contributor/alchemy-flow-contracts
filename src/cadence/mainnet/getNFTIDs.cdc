import NonFungibleToken from 0x1d7e57aa55817448
import ARTIFACTPack from 0x24de869c5e40b2eb
import ARTIFACT from 0x24de869c5e40b2eb
import ARTIFACTPackV3 from 0x24de869c5e40b2eb
import ARTIFACTV2 from 0x24de869c5e40b2eb

pub fun main(ownerAddress: Address): {String: [UInt64]} {
    let owner = getAccount(ownerAddress)
    let ids: {String: [UInt64]} = {}


    if let col = owner.getCapability(ARTIFACTPack.collectionPublicPath)
    .borrow<&{ARTIFACTPack.CollectionPublic}>() {
        ids["ARTIFACTPack"] = col.getIDs()
    }

    if let col = owner.getCapability(ARTIFACT.collectionPublicPath)
    .borrow<&{ARTIFACT.CollectionPublic}>() {
        ids["ARTIFACT"] = col.getIDs()
    }

    if let col = owner.getCapability(ARTIFACTPackV3.collectionPublicPath)
    .borrow<&{ARTIFACTPackV3.CollectionPublic}>() {
        ids["ARTIFACTPackV3"] = col.getIDs()
    }

    if let col = owner.getCapability(ARTIFACTV2.collectionPublicPath)
    .borrow<&{ARTIFACTV2.CollectionPublic}>() {
        ids["ARTIFACTV2"] = col.getIDs()
    }

    return ids
}
