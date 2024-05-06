declare module "@salesforce/apex/SelfBorrowBookComponentController.setBookSelfFlag" {
  export default function setBookSelfFlag(param: {readerId: any, bookDetailsId: any}): Promise<any>;
}
declare module "@salesforce/apex/SelfBorrowBookComponentController.selfBorrowBooks" {
  export default function selfBorrowBooks(param: {readerId: any}): Promise<any>;
}
declare module "@salesforce/apex/SelfBorrowBookComponentController.clearselfFlag" {
  export default function clearselfFlag(): Promise<any>;
}
