declare module "@salesforce/apex/CorningTestExtension.getUserList" {
  export default function getUserList(): Promise<any>;
}
declare module "@salesforce/apex/CorningTestExtension.getBookList" {
  export default function getBookList(param: {userId: any}): Promise<any>;
}
declare module "@salesforce/apex/CorningTestExtension.getAllOpps" {
  export default function getAllOpps(): Promise<any>;
}
