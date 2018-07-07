import React, { Component } from 'react'
import { Form, InputNumber, Button, message } from 'antd';

import Common from './Common';

const FormItem = Form.Item;

class Fund extends Component {
  constructor(props) {
    super(props);

    this.state = {};
  }

  handleSubmit = (ev) => {
    ev.preventDefault();
    const { payroll, account, web3 } = this.props;
    payroll.addFund({
      from: account,
      value: web3.toWei(this.state.fund)
    })
    .then(() => this.CommonRef.getEmployerInfo())
    .catch(err => message.error(`addFund error: ${err}`))
  }
  onRef = (ref) => {
    this.CommonRef = ref
  }

  render() {
    return (
      <div>
        <Common {...this.props} onRef={this.onRef} />

        <Form layout="inline" onSubmit={this.handleSubmit}>
          <FormItem>
            <InputNumber
              min={1}
              onChange={fund => this.setState({fund})}
            />
          </FormItem>
          <FormItem>
            <Button
              type="primary"
              htmlType="submit"
              disabled={!this.state.fund}
            >
              增加资金
            </Button>
          </FormItem>
        </Form>
      </div>
    );
  }
}

export default Fund