// multiSelectLookup.js
import { LightningElement, track, api } from 'lwc';

export default class CustomPicklist extends LightningElement {
    @track options = []; // 这个数组用来存储下拉列表中的所有选项
    @track selectedOptions = []; // 用于存储用户已选择的选项
    @track values = []; // 用于存储用户选择的值（来自selectedOptions）

    // 组件初始化后，可以通过调用Apex获取初始选项数据
    connectedCallback() {
        // Populate options with an initial set of values
        this.options = [
            // 这些应该是从Apex类获取的实际选项
            { label: 'Option 1', value: 'option1' },
            { label: 'Option 2', value: 'option2' },
            { label: 'Option 3', value: 'option3' },
            // ... 其他选项
        ];
    }

    // 可以处理聚焦事件，例如显示搜索结果或其他用户界面的交互
    handleFocus() {
        // 处理聚焦事件
    }

    // 处理失焦事件，通常用于关闭下拉列表或验证用户输入
    handleBlur() {
        // 处理失焦事件
    }

    // 当用户从下拉列表中选择一个选项时，此方法被调用
    handleChange(event) {
    	console.log('handleChange');
        // 从模板中获取当前选项列表
        const { options } = this;
        // 获取用户选择的值
        const selectedValue = event.detail.value;
        
        // 从选项列表中找到对应用户所选的项
        const selectedOption = options.find(option => option.value === selectedValue);

        // 如果这个选项存在且尚未被选中，添加到selectedOptions数组中
        if (selectedOption && !this.selectedOptions.includes(selectedOption)) {
            this.selectedOptions = [...this.selectedOptions, selectedOption];
            this.values = [...this.values, selectedValue];
        }

        // 清空下拉列表的当前选择，以便用户可以进行新的选择
        this.template.querySelector('lightning-combobox').value = null;
    }

    // 当用户希望从已选择的选项中移除一个选项时，调用此方法
    handleRemove(event) {
    	console.log('handleRemove');
        // 获取通过data-recordid传递的值，这将用于确定要删除的选项
        const recordId = event.currentTarget.dataset.recordid;
        // 在已选择的选项中找到与recordId相同的选项的索引
        const index = this.selectedOptions.findIndex(option => option.value === recordId);
        // 如果该选项存在，从已选择的选项数组中移除，并触发视图更新
        if (index !== -1) {
            this.selectedOptions.splice(index, 1);
            this.selectedOptions = [...this.selectedOptions]; // 通过解构赋值触发更新
            this.values = this.selectedOptions.map(option => option.value); // 更新值数组
        }
    }
}