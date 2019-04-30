import React, { PureComponent } from 'react';
import { Form, Input, Button } from 'antd';

let updateIsSubmited;

const FormItem = Form.Item;

class SampleComponent extends PureComponent {
  componentDidMount() {
    const { form } = this.props;

    console.log(form.getFieldValue('userPassword'));
    this.formId = 'testForm';
  }

  handleFormSubmit = () => {
    const { form } = this.props;

    form.validateFieldsAndScroll(undefined, { first: false }, (errors, values) => {
      console.log(errors);
      console.log(values);
    });
  };

  render() {
    const { form: { getFieldDecorator } } = this.props;

    return (
      <Form id={this.formId} layout="vertical" className="wm-bot-form">
        {/*<StaticMessage*/}
          {/*visible={!isLoading && !isCreateForm && !isValidForWMPreview}*/}
          {/*text="Note: Bot will not appear in Preview and cannot be published due to some missing fields."*/}
          {/*level="warning"*/}
        {/*/>*/}
        <FormItem
          label={<span>User name</span>}
          required={true}
          key='userName'
        >
          {getFieldDecorator('userName', {
            rules: [
              {
                required: true,
                message: 'User name is required',
              },
              {
                pattern: /^.{3,50}$/,
                message: 'User name can contain from 3 to 50 characters',
              }
            ]
          })(<Input placeholder='User name'/>)}
        </FormItem>

        <FormItem
          label={<span>User password</span>}
          required={true}
          key='userPassword'
        >
          {getFieldDecorator('userPassword', {
            rules: [
              {
                required: true,
                message: 'User name is required',
              },
              {
                pattern: /^.{3,50}$/,
                message: 'User name can contain from 3 to 50 characters',
              }
            ]
          })(<Input type='password' placeholder='Password'/>)}
        </FormItem>

        <div>
          <Button
            onClick={this.handleFormSubmit}
          >Send form</Button>
        </div>

      </Form>
    );
  }
}

const mapPropsToFields = (props) => {
  return {
    userName: Form.createFormField({ value: null }),
    userEmail: Form.createFormField({ value: null }),
    userPassword: Form.createFormField({ value: null }),
  };
};

const onFieldsChange = (props, fields) => {
  console.log('onFieldsChange triggered');

  if (!Object.keys(fields).length) {
    return;
  }

  if (updateIsSubmited && typeof updateIsSubmited === 'function') {
    updateIsSubmited();
  }

  // const { settingsStore } = props;
  //
  // if (settingsStore) {
  //   settingsStore.allowBackToEditor(false);
  // }
};

const AntFormSampleComponent = Form.create({ mapPropsToFields, onFieldsChange })(SampleComponent);

export {
  AntFormSampleComponent
}
export default AntFormSampleComponent;
