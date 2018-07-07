import React, { Component } from 'react'
import { Table, Button, Modal, Form, InputNumber, Input, message, Popconfirm } from 'antd';

import EditableCell from './EditableCell';

const FormItem = Form.Item;
const gas = 3000000;

class EmployeeList extends Component {
  constructor(props) {
    super(props);

    this.state = {
      loading: true,
      employees: [],
      showModal: false
    };
  }

  componentDidMount() {
    const { payroll, account: from } = this.props;
    payroll.getEmployerInfo.call({
      from
    })
    .then(result => {
      const employeeCount = result[2].toNumber();

      this.setState({loading: false});

      if (employeeCount === 0) {
        return;
      }

      this.loadEmployees(employeeCount);
    });
  }

  loadEmployees(employeeCount) {
    const { payroll, account: from, web3 } = this.props;
    const requests = [];

    for(let index = 0; index < employeeCount; index++){
      requests.push(payroll.getEmployeeInfo.call(index, {
        from,
        gas
      }))
    }

    Promise.all(requests)
      .then(values => {
        const employees = values.map(values => ({
          key: values[0],
          address: values[0],
          salary: web3.fromWei(values[1].toNumber()),
          lastPaidDay: new Date(values[2].toNumber() * 1000).toString()
        }))

        this.setState({ employees })
      })
  }

  addEmployee = () => {
    const { address, salary } = this.state;
    const { payroll, account: from } = this.props;
    const _salary = parseInt(salary) || 0;

    payroll.addEmployee(address, _salary, {
      from,
      gas
    })
    .then(() => {
      const employee = {
        key: address, 
        address, 
        salary: _salary,
        lastPaidDay: new Date().toString()
      };
      const employees = this.state.employees.concat(employee);

      this.setState({
        employees
      })
    })
    .catch((err) => {
      message.error(`addEmployee error: ${err}`)
    })
    .finally(() => this.setState({ showModal: false }))
  }

  updateEmployee = (address, salary) => {
    const { payroll, account: from } = this.props;
    const _salary = parseInt(salary) || 0;

    payroll.updateEmployee(address, _salary, {
      from,
      gas
    })
    .then(() => {
      const employees = this.state.employees.map(e => {
        if (e.address === address) {
          e.salary = _salary;
        }
        return e
      });
      
      this.setState({ employees })
    })
    .catch(err => message.error(`updateEmployee error: ${err}`))
  }

  removeEmployee = (employeeId) => {
    const { payroll, account: from } = this.props;

    payroll.removeEmployee(employeeId, {
      from,
      gas
    })
    .then(() => {
      const employees = this.state.employees.filter(e => e.address !== employeeId);

      this.setState({ employees })
    })
    .catch(err => message.error(`removeEmployee error: ${err}`))
  }

  renderModal() {
      return (
      <Modal
          title="增加员工"
          visible={this.state.showModal}
          onOk={this.addEmployee}
          onCancel={() => this.setState({showModal: false})}
      >
        <Form>
          <FormItem label="地址">
            <Input
              onChange={ev => this.setState({address: ev.target.value})}
            />
          </FormItem>

          <FormItem label="薪水">
            <InputNumber
              min={1}
              onChange={salary => this.setState({salary})}
            />
          </FormItem>
        </Form>
      </Modal>
    );

  }

  render() {
    const { loading, employees } = this.state;
    const columns = [{
      title: '地址',
      dataIndex: 'address',
      key: 'address',
    }, {
      title: '薪水',
      dataIndex: 'salary',
      key: 'salary',
      render: (text, record) => (
        <EditableCell
          value={text}
          onChange={ this.updateEmployee.bind(this, record.address) }
        />
      )
    }, {
      title: '上次支付',
      dataIndex: 'lastPaidDay',
      key: 'lastPaidDay',
    }, {
      title: '操作',
      dataIndex: '',
      key: 'action',
      render: record => (
        <Popconfirm title="你确定删除吗?" onConfirm={() => this.removeEmployee(record.address)}>
          <a href="javascript:;">Delete</a>
        </Popconfirm>
      )
    }];
    
    return (
      <div>
        <Button
          type="primary"
          onClick={() => this.setState({showModal: true})}
        >
          增加员工
        </Button>

        {this.renderModal()}

        <Table
          loading={loading}
          dataSource={employees}
          columns={columns}
        />
      </div>
    );
  }
}

export default EmployeeList
