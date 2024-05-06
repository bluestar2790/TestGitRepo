declare module "@salesforce/apex/ReaderReturnBookComponentController.getBorrow" {
  export default function getBorrow(): Promise<any>;
}
declare module "@salesforce/apex/ReaderReturnBookComponentController.getByName" {
  export default function getByName(param: {name: any}): Promise<any>;
}
declare module "@salesforce/apex/ReaderReturnBookComponentController.setReturnDate" {
  export default function setReturnDate(param: {borrowIdList: any}): Promise<any>;
}
declare module "@salesforce/apex/ReaderReturnBookComponentController.setAutoReturnDate" {
  export default function setAutoReturnDate(param: {borrowchildBookId: any}): Promise<any>;
}
